abstract class Storage {
  Future<bool?> write(String key, Object data);

  Future<Object?> read(String key);

  Future<bool?> remove(String key);

  Future<bool?> removeAll();
}
