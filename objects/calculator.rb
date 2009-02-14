%w[extensions].each do |file|
  require File.join("#{File.dirname(__FILE__)}", "#{file}.rb")
end

module Calculator
  DEFAULT_XOVER_FREQ    = 0.1
  DEFAULT_MUTATION_FREQ = 0.25
  
  def self.get_normal_random_variable
    x = y = sum = 0
    loop do
      x = get_uniform_random_variable
      y = get_uniform_random_variable
      break if (sum = (x ** 2) + (y ** 2)) < 1
    end
    rand(2).zero? ? convert(x, sum) : convert(y, sum)
  end
  
  def self.get_uniform_random_variable
    rand(0) * random_sign_change
  end
  
  def self.random_sign_change
    rand(2).zero? ? 1 : -1
  end
  
  def self.convert(variable, sum)
    # http://en.wikipedia.org/wiki/Marsaglia_polar_method
    return 0 if sum.zero?
    variable * Math.sqrt(-2 * Math.log(sum) / sum)
  end
  
  def self.generate_value(max)
    if max.is_a? Float
      rand(0)
    elsif max.is_a? Fixnum
      rand(max)
    else
      raise(ArgumentError, "Can't generate values of type #{max.class} in Calculator.generate_value(max)")
    end
  end
  
  def self.meiosis(chromosome_1, chromosome_2, options = {})
    if chromosome_1.get_parameters != chromosome_2.get_parameters
      raise(ArgumentError, "The two chromosomes don't have matching parameters")
    end
    
    aligned_genes    = [chromosome_1.genes, chromosome_2.genes]
    current_sequence = rand(2)
    xover_freq       = options[:xover_freq]    || DEFAULT_XOVER_FREQ
    mutation_freq    = options[:mutation_freq] || DEFAULT_MUTATION_FREQ
    
    num_genes, num_points, image_dimensions = chromosome_1.get_parameters
    
    chromosome_settings = returning({}) do |new_chromosome_settings|
      (0...num_genes).each do |index|
        current_sequence = read_from(current_sequence, xover_freq)
        new_chromosome_settings[:"gene_#{index}"] = generate_gene_from(aligned_genes[current_sequence][index], mutation_freq)
      end
    end
    
    Chromosome.new(num_genes, num_points, image_dimensions, chromosome_settings)
  end
  
  def self.generate_gene_from(gene, mutation_freq = DEFAULT_MUTATION_FREQ)
    points = gene.polygon.points
    
    returning({}) do |gene_settings|      
      (0...gene.polygon.num_points).each do |index|
        gene_settings[:"trait_x_#{index}"] = settings_hash_for(points[index].x, mutation_freq)
        gene_settings[:"trait_y_#{index}"] = settings_hash_for(points[index].y, mutation_freq)
      end

      gene.color.to_hash.each do |color, trait|
        gene_settings[:"trait_#{color}"] = settings_hash_for(trait, mutation_freq)
      end
    end
  end
  
  def self.settings_hash_for(trait, mutation_freq = DEFAULT_MUTATION_FREQ)
    {
      :default            => mutate(trait, mutation_freq),
      :standard_deviation => trait.standard_deviation
    }
  end
  
  def self.mutate(trait, mutation_freq = DEFAULT_MUTATION_FREQ)
    rand(0) < mutation_freq ? trait.mutated_value : trait.value
  end
  
  def self.read_from(current_sequence, xover_freq = DEFAULT_XOVER_FREQ)
    # Changes current read sequence randomly with a probability of xover_freq
    rand(0) < xover_freq ? flip(current_sequence) : current_sequence
  end
  
  def self.flip(current_sequence)
    # XOR flip
    current_sequence ^ 1
  end
end