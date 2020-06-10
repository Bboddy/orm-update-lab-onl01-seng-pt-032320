require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  @@all= []
  
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
    @@all << self
  end
  
  def self.table_exists(name)
    sql = <<-SQL
      if exists (select 1 from information_schema.tables where table_name = '?')
    SQL
    
    DB[:conn].execute(sql, name)
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT, 
      grade INTEGER);
    SQL
    
     DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    if !self.table_exists(self.name)
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
   
      DB[:conn].execute(sql, self.name, self.grade)
   
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      sql = <<-SQL #UPDATE [table name] SET [column name] = [new value] WHERE [column name] = [value];
        UPDATE INTO [students] SET [name, grade]  = [?, ?]
      SQL
   
      DB[:conn].execute(sql, self.name, self.grade)
   
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def self.create(input)
    student = Student.new(input[:name], input[:grade])
    student.save
    return student
  end
end
