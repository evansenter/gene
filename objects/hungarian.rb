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
    @mask    = Array.new(@length) { Array.new(@length, EMPTY) }
    @covered = { :rows => Array.new(@length, false), :columns => Array.new(@length, false) }
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
        @covered[:rows][row] = @covered[:columns][column] = true
      end
    end
    @covered[:rows].map! { false }
    @covered[:columns].map! { false }
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
      raise "GO TO STEP 5" if row_mask_values_for(row).all? { |value| value != STAR } #####
      @covered[:rows][row] = true
      @covered[:columns][row_mask_values_for(row).index(STAR)] = false
    end
  end
  
  def find_uncovered_zero
    traverse_indices do |row, column|
      return [row, column] if @matrix[row][column].zero? && !location_covered?(row, column)
    end
    [-1, -1]
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