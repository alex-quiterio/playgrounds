class Problem

  def mark_iteration(val, num)
    raise NotImplementedError
  end

  def unmark_iteration(val, num)
    raise NotImplementedError
  end

  def iteration_counter
    raise NotImplementedError
  end

  def is_safe?(val, num)
    raise NotImplementedError
  end

  def print
    raise NotImplementedError
  end

  def find_new_coords
    raise NotImplementedError
  end

  def stop_condition?
    coords = find_new_coords
    return coords == nil
  end
end
