require 'sqlite3'

class Database

  def initialize
    @db = SQLite3::Database.new 'users.db'

    @db.execute <<-SQL
      create table if not exists users (
        username text primary key,
        password text
      )
    SQL
  end

  def users

    sql = <<-SQL
      select username
      from users
    SQL

    @db.execute(sql).map { |row| { username: row[0] } }
  end

  def add_user(data)

    sql = <<-SQL
      insert into users (username, password)
      values (?, ?)
    SQL
    
    @db.execute sql, [data['username'], data['password']]

    true
  rescue SQLite3::ConstraintException
    false
  end

  def get_user(username)

    sql = <<-SQL
      select username
      from users
      where username = ?
    SQL

    (@db.execute sql, [username]).map { |row| { username: row[0] } }.first
  end

  def match(username, password)

    sql = <<-SQL
      select username
      from users
      where username = ?
      and password = ?
    SQL

    (@db.execute sql, [username, password]).map { |row| { username: row[0] } }.first
  end

  def delete_user(username)

    sql = <<-SQL
      delete from users
      where username = ?
    SQL

    @db.execute sql [username]
  end

  def delete_all
    @db.execute 'delete from users'
  end

end
