#!/usr/bin/env ruby

# COMPARISON SCRIPT
#
# require "munkres.rb"
# require "hungarian.rb"
# 
# m = Munkres.new
# h = Hungarian.new
# 
# 1000.times do
#   length = rand(25) + 1
#   array  = Array.new(length) { Array.new(length, rand(1000)) }
#   
#   m_sol = m.compute(array)
#   h_sol = h.solve(array)
#   
#   if m_sol != h_sol
#     p "Array"
#     p array
#     p "Munkres"
#     p m_sol
#     p "Hungarian"
#     p h_sol
#   else
#     print "."
#   end
# end

"""
Introduction
============

The Munkres module provides an implementation of the Munkres algorithm
(also called the Hungarian algorithm or the Kuhn-Munkres algorithm),
useful for solving the Assignment Problem. 

For information about the algorithm refer to the Wikipedia article:
http://en.wikipedia.org/wiki/Hungarian_algorithm

This version is based on Brian Clapper's Python implementation at
http://www.clapper.org/software/python/munkres/

Usage
=====

  require 'munkres'

  m = Munkres.new
  indexes = m.compute(a)
  for index in indexes
    puts ['(',row,',',col,') => ',a[row][col]].join
  end

Author
======

This Ruby implementation was written by Michael Cheng, <mike@mikecheng.net>

"""

class Munkres 
  """
  Ruby implementation of the Munkres assignment algorithm.
  """

  def compute(matrix)
    """
    Compute the indexes for the lowest-cost pairings between rows and
    columns in the database. Returns a list of [row,column] pairs
    that can be used to traverse the matrix.

    The matrix must be square.
    """
    @C           = matrix.collect { |row| row.dup }
    @row_covered = Array.new(matrix.size, false)
    @col_covered = Array.new(matrix.size, false)
    @path        = Array.new(matrix.size*2).map { Array.new(matrix.size*2, 0) }
    @marked      = Array.new(matrix.size).map { Array.new(matrix.size, 0) }

    stepno = 1
    while stepno != -1
#      puts "__step#{stepno}"
      stepno = eval("__step#{stepno}")
    end

    # Look for the starred columns
    results = []
    @marked.each_with_index do |row,r|
      results << [r,row.index(1)]
    end
    raise "AssignmentMismatchError" unless results.length == @C.size

    return results
  end

  def __step1
    """
    For each row of the matrix, find the smallest element and
    subtract it from every element in its row. Go to Step 2.
    """
    @C.each do |row|
      row_min = row.min  # find the minimum of this row
      row.collect! { |value| value - row_min } # subtract from every element
    end

    return 2
  end

  def __step2
    """
    Find a zero (Z) in the resulting matrix. If there is no starred
    zero in its row or column, star Z. Repeat for each element in the
    matrix. Go to Step 3.
    """
    @C.each_with_index do |row,r|
      if c = row.index(0) and not @col_covered[c]
        @marked[r][c] = 1
        @col_covered[c] = true
      end    
    end
    __clear_covers

    return 3 
  end

  def __step3
    """
    Cover each column containing a starred zero. If K columns are
    covered, the starred zeros describe a complete set of unique
    assignments. In this case, Go to DONE, otherwise, Go to Step 4.
    """
    count = 0
    @marked.each_with_index do |row,r|
      row.each_with_index do |value,c|
        if value == 1
          @col_covered[c] = true
          count += 1
        end
      end
    end

    return count < @C.size ? 4 : -1
  end

  def __step4
    """
    Find a noncovered zero and prime it. If there is no starred zero
    in the row containing this primed zero, Go to Step 5. Otherwise,
    cover this row and uncover the column containing the starred
    zero. Continue in this manner until there are no uncovered zeros
    left. Save the smallest uncovered value and Go to Step 6.
    """
    while (r,c = __find_a_zero) != [-1,-1]
      @marked[r][c] = 2
      if sz = @marked[r].index(1)  # found starred zero
        @row_covered[r]  = true
        @col_covered[sz] = false
      else                         # no starred zero
        @Z0 = [r,c]
        return 5
      end
    end

    return 6
  end

  def __step5
    """
    Construct a series of alternating primed and starred zeros as
    follows. Let Z0 represent the uncovered primed zero found in Step 4.
    Let Z1 denote the starred zero in the column of Z0 (if any).
    Let Z2 denote the primed zero in the row of Z1 (there will always
    be one). Continue until the series terminates at a primed zero
    that has no starred zero in its column. Unstar each starred zero
    of the series, star each primed zero of the series, erase all
    primes and uncover every line in the matrix. Return to Step 3
    """
    count = 0
    @path[count][0], @path[count][1] = @Z0
    
    while r = @marked.transpose[@path[count][1]].index(1) # found starred zero
      count += 2
      @path[count-1][0] = r                                 # star row index
      @path[count-1][1] = @path[count-2][1]
      @path[count][0]   = @path[count-1][0]
      @path[count][1]   = @marked[@path[count][0]].index(2) # prime col index
    end

    __convert_path count
    __clear_covers
    __erase_primes

    return 3
  end

  def __step6
    """
    Add the value found in Step 4 to every element of each covered
    row, and subtract it from every element of each uncovered column.
    Return to Step 4 without altering any stars, primes, or covered
    lines.
    """
    minval = __find_smallest
    @C.each_with_index do |row,r|
      row.each_with_index do |col,c|
        if @row_covered[r] then @C[r][c] += minval end
        if not @col_covered[c] then @C[r][c] -= minval end
      end
    end

    return 4
  end

  def __find_smallest
    """Find the smallest uncovered value in the matrix."""
    minval = 1.0/0 # infinity
    @C.each_with_index do |row,r|
      row.each_with_index do |value,c|
        if minval > value and not @row_covered[r] and not @col_covered[c]
          minval = value
        end
      end
    end
    return minval
  end

  def __find_a_zero
    """Find an uncovered element with value 0"""
    zero = [-1,-1]
    @C.each_with_index do |row,r|
      row.each_with_index do |value,c|
        if @C[r][c] == 0 and 
             not @row_covered[r] and 
               not @col_covered[c]
          zero = [r,c]
        end
      end
      if not zero == [-1,-1] then return zero end
    end
    return zero
  end

  def __convert_path(count)
    (0..count).each do |i|
      @marked[@path[i][0]][@path[i][1]] ^= 1
      @marked[@path[i][0]][@path[i][1]] &= 1
    end
  end

  def __clear_covers
    """Clear all covered matrix cells"""
    @row_covered.fill(false) 
    @col_covered.fill(false)
  end

  def __erase_primes
    """Erase all prime markings"""
    @marked.each do |row|
      row.collect! { |value| (value == 2) ? 0 : value }
    end
  end
end
