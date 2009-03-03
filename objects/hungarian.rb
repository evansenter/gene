%w[extensions].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

class Hungarian
  EMPTY = 0
  STAR  = 1
  PRIME = 2
  
  def initialize(matrix)
    @matrix  = matrix
    @length  = @matrix.length
    @mask    = Array.new(@length) { Array.new(@length, EMPTY) }                               # 2D array of constants (listed above)
    @covered = { :rows => Array.new(@length, false), :columns => Array.new(@length, false) }  # Boolean arrays
  end
  
  def solve
  end
  
  private
  
  def minimize_rows
    @matrix.map! do |row|
      min_value = row.min
      row.map { |element| element - min_value }
    end
  end
  
  def star_zeroes
    traverse_indices do |row, column|
      if @matrix[row][column].zero? && !location_covered?(row, column)
        @mask[row][column] = STAR
        cover_cell(row, column)
      end
    end
    
    reset_covered_hash
  end
  
  def mask_columns
    (0...@length).each do |index|
      @covered[:columns][index] = true if column_mask_values_for(index).any? { |value| value == STAR }
    end
    
    if @covered[:columns].all?
      raise "FINISHED" #####
    end
  end
  
  def prime_zeroes
    while (row, column = find_uncovered_zero) != [-1, -1]
      @mask[row][column] = PRIME
      
      if star_loc_in_row = row_mask_values_for(row).index(STAR)
        return row, column
      else
        @covered[:rows][row] = true
        @covered[:columns][star_loc_in_row] = false
      end
    end
  end
  
  def augment_path(path_start)
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
    
    path = [path_start]
    
  end
  
  def find_uncovered_zero
    traverse_indices do |row, column|
      return [row, column] if @matrix[row][column].zero? && !location_covered?(row, column)
    end
    [-1, -1]
  end
  
  def cover_cell(row, column)
    @covered[:rows][row] = @covered[:columns][column] = true
  end
  
  def reset_covered_hash
    @covered[:rows].map! { false }
    @covered[:columns].map! { false }
  end
  
  def location_covered?(row, column)
    @covered[:rows][row] || @covered[:columns][column]
  end
  
  def row_mask_values_for(row)
    (0...@length).map { |column| @mask[row][column] }
  end
  
  def column_mask_values_for(column)
    (0...@length).map { |row| @mask[row][column] }
  end
  
  def traverse_indices(&block)
    (0...@length).each do |row|
      (0...@length).each do |column|
        yield row, column
      end
    end
  end
end