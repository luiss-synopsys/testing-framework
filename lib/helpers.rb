class Helper

  def self.get_status()
    raise("StatusFileDoesNotExists") unless File.exists?(DirManager.get_status_file)
    return JSON.parse(File.read(DirManager.get_status_file))
  end
  
  def self.set_status(result, task)
    data = "{}"
    file = DirManager.get_status_file
    data = File.read(file) if(File.exists?(file))
    status = JSON.parse(data)
    status[task] = result
    DirManager.create_dir_for_file(file)
    File.write(file, JSON.pretty_generate(status))
    puts (result) ? "Passed" : "Failed"
  end

  def self.set_internal_vars(task)
    VarManager.instance.set_internal("@SOURCE", "#{DirManager.pwd}/sources")
    VarManager.instance.set_internal("@BUILDNAME", task.to_s)
    VarManager.instance.set_internal("@PERSISTENT_WS", "#{DirManager.get_persistent_ws_path}/#{task.to_s}")
    VarManager.instance.set_internal("@WORKSPACE", "#{DirManager.get_build_path}/#{task}")
    VarManager.instance.set_internal("@CONFIG_SOURCE_PATH", "#{DirManager.get_framework_path}/.config")
  end

  def self.check_environment(args)
    return if (%w[init clone] & args).any?
    begin
      raise "NotTBSFEnvironmentException" if !File.directory? (DirManager.get_framework_path)
    rescue Exception => e
      abort ("ERROR: Not in a TBSF Environment") if e.message == "NotTBSFEnvironmentException"
    end
  end

  def self.lock_mg(type, args)
    return if !(%w[execute set git sources clean compare publish] & args).any?
    if type == :LOCK
      begin
        lock()
      rescue Exception => e
        abort("WARNING: Could not get Lock") if e.message == "CouldNotGetLockException"
      end
    elsif type == :UNLOCK
      unlock()
    end
  end

  def self.lock
    lock_file = DirManager.get_lock_file
    raise "CouldNotGetLockException" if File.exists? lock_file
    puts "DEBUG: LOCKING"
    system "echo '' > #{lock_file}"
  end

  def self.unlock
    puts "DEBUG: UNLOCKING"
    lock_file = DirManager.get_lock_file
    return system("rm -rf #{lock_file}") if File.exists? lock_file
  end
end