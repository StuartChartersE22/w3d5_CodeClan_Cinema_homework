require('PG')

class SqlRunner

  def self.run(sql, values =[])
    begin
      db = PG.connect({
        dbname: 'cinema',
        host: 'localhost'
        })
      db.prepare('query', sql)
      results = db.exec_prepared('query', values)
    ensure
      db.close() if db != nil
    end
  return results
  end

  def self.run_unsanitised(sql, values=[])
    begin
      db = PG.connect({
        dbname: 'cinema',
        host: 'localhost'
        })
      results = db.exec(sql, values)
    ensure
      db.close() if db != nil
    end
    return results
  end

end
