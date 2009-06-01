module Meiosis
  include Geometry
  
  def self.included(base)
    base.instance_eval "include InstanceMethods"
    base.extend ClassMethods
  end
  
  module InstanceMethods
    private
    
    def genes_from_alignment_map(alignment)
      alignment.map { |index| @genes[index] }
    end
  end
  
  module ClassMethods
    def meiosis(chromosome_1, chromosome_2, options = {})
      chromosomes = [chromosome_1, chromosome_2]
      validate_meiosis_for(chromosomes)
  
      genes_for        = aligned_chromosomes(chromosome_1, chromosome_2)      
      fitness_for      = chromosomes.map(&:fitness)
      current_sequence = rand(2)
      xover_freq       = options[:xover_freq]    || default_xover_freq
      mutation_freq    = options[:mutation_freq] || default_mutation_freq
  
      num_genes, num_points, image_dimensions = chromosomes.first.get_parameters
  
      chromosome_settings = generate_chromosome_settings(num_genes, genes_for, fitness_for, current_sequence, xover_freq, mutation_freq)
      Chromosome.new(num_genes, num_points, image_dimensions, chromosome_settings)
    end

    private

    def validate_meiosis_for(chromosomes)
      if chromosomes.first.get_parameters != chromosomes.last.get_parameters
        raise(ArgumentError, "The two chromosomes don't have matching parameters")
      elsif !chromosomes.all?(&:fitness)
        raise(ArgumentError, "Both chromosomes need to have a fitness value")
      end
    end

    def aligned_chromosomes(chromosome_1, chromosome_2)
      aligned_chromosomes = Geometry.align_crossover_for(chromosome_1, chromosome_2)
  
      [
        chromosome_1.genes_from_alignment_map(aligned_chromosomes[:chromosome_1]),
        chromosome_2.genes_from_alignment_map(aligned_chromosomes[:chromosome_2])
      ]
    end

    def generate_chromosome_settings(num_genes, genes_for, fitness_for, current_sequence, xover_freq, mutation_freq)
      returning({}) do |new_chromosome_settings|
        (0...num_genes).each do |index|
          current_sequence = read_from(current_sequence, xover_freq)
          new_chromosome_settings[:"gene_#{index}"] = generate_gene_from(genes_for[current_sequence][index], fitness_for[current_sequence], mutation_freq)
        end
      end
    end

    def generate_gene_from(gene, fitness, mutation_freq = default_mutation_freq)
      points = gene.polygon.points
  
      returning({}) do |gene_settings|      
        (0...gene.polygon.num_points).each do |index|
          [:x, :y].each { |axis| gene_settings[:"trait_#{axis}_#{index}"] = settings_hash_for(points[index].send(axis), fitness, mutation_freq) }
        end

        gene.color.to_hash.each do |color, trait|
          gene_settings[:"trait_#{color}"] = settings_hash_for(trait, fitness, mutation_freq)
        end
      end
    end

    def settings_hash_for(trait, fitness, mutation_freq = default_mutation_freq)
      {
        :default            => mutate(trait, mutation_freq),
        :standard_deviation => Trait.new_standard_deviation_from(fitness)
      }
    end

    def mutate(trait, mutation_freq = default_mutation_freq)
      rand(0) < mutation_freq ? trait.mutated_value : trait.value
    end

    def read_from(current_sequence, xover_freq = default_xover_freq)
      rand(0) < xover_freq ? flip(current_sequence) : current_sequence
    end

    def flip(current_sequence)
      current_sequence ^ 1
    end
  end
end