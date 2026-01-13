-- Create a new schema
-- A schema is a logical container for database objects like tables, views, and stored procedures
-- It helps in organizing database objects and can be used for access control
CREATE SCHEMA GA1;
GO

-- Create a sample table in the new schema
-- This table will store employee information
CREATE TABLE GA1.EmployeeData
(
    EmployeeID INT PRIMARY KEY,
    -- Unique identifier for each employee
    FirstName NVARCHAR(50),
    -- First name of the employee
    LastName NVARCHAR(50),
    -- Last name of the employee
    Salary DECIMAL(10, 2),
    -- Employee's salary (allows for 2 decimal places)
    Department NVARCHAR(50)
    -- Department where the employee works
);
GO

-- Insert some sample data into the EmployeeData table
-- This data will be used to test our permissions later
INSERT INTO GA1.EmployeeData
    (EmployeeID, FirstName, LastName, Salary, Department)
VALUES
    (1, 'John', 'Doe', 50000.00, 'Sales'),
    (2, 'Jane', 'Smith', 60000.00, 'HR'),
    (3, 'Bob', 'Johnson', 55000.00, 'IT'),
    (4, 'Alice', 'Williams', 65000.00, 'Finance');
GO