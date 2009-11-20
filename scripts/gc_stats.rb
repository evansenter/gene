def gc_statistics(description = "", options = {})
  # Do nothing if we don't have the patched Ruby GC.
  yield and return unless GC.respond_to? :enable_stats

  GC.enable_stats || GC.clear_stats
  GC.disable if options[:disable_gc]

  yield

  stat_string = description + ": "
  stat_string += "allocated: #{GC.allocated_size/1024}K total in #{GC.num_allocations} allocations, "
  stat_string += "GC calls: #{GC.collections}, "
  stat_string += "GC time: #{GC.time / 1000} msec"

  GC.log stat_string
  GC.dump if options[:show_gc_dump]

  GC.enable if options[:disable_gc]
  GC.disable_stats
end