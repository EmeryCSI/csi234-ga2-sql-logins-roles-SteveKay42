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


-- Part 3: Creating Users with Different Levels of Access
-- Create logins. Logins are created on the SERVER level in the master database
-- Be sure you run this code ON MASTER
-- A login is a security principal at the server level that allows connection to the SQL Server instance
CREATE LOGIN HRManager WITH PASSWORD = 'HRPass123!';
CREATE LOGIN SalesRep WITH PASSWORD = 'SalesPass123!';
CREATE LOGIN ITSupport WITH PASSWORD = 'ITPass123!';
GO

-- Verify that the logins were created
SELECT *
FROM sys.sql_logins


-- Create users for the logins
-- A user is a security principal at the database level
-- Switch back to AdventureWorksLT before running this Query
-- Users are mapped to logins and are used to control access to database objects
CREATE USER HRManagerUser FOR LOGIN HRManager;
CREATE USER SalesRepUser FOR LOGIN SalesRep;
CREATE USER ITSupportUser FOR LOGIN ITSupport;
GO

-- Verify that the users were created
SELECT *
FROM sys.database_principals

-- The difference between a login and a user:
-- Login: Server-level principal, used for authentication (connecting to the server)
-- User: Database-level principal, used for authorization (accessing objects within a database)


-- Create roles
-- Roles are used to group users and assign permissions collectively
CREATE ROLE HRRole;
CREATE ROLE SalesRole;
CREATE ROLE ITRole;
GO

-- Assign permissions to roles
-- GRANT: Gives a security principal permission to perform an action
-- SCHEMA::GA1 applies the permission to all objects within the GA1 schema

-- SELECT: Allows reading data
-- INSERT: Allows adding new rows
-- UPDATE: Allows modifying existing data
-- DELETE: Allows removing rows
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::GA1 TO HRRole;

-- SalesRole only needs to view employee data, not modify it
GRANT SELECT ON GA1.EmployeeData TO SalesRole;

-- ITRole needs to view data and update certain information
GRANT SELECT, UPDATE ON GA1.EmployeeData TO ITRole;
GO

-- Assign users to roles
-- This links the users to their respective roles, granting them the role's permissions
ALTER ROLE HRRole ADD MEMBER HRManagerUser;
ALTER ROLE SalesRole ADD MEMBER SalesRepUser;
ALTER ROLE ITRole ADD MEMBER ITSupportUser;
GO


-- Column-level permissions allow for more granular control over data access

-- DENY: Explicitly prevents a security principal from performing an action
-- This ensures that SalesRole cannot view salary information
DENY SELECT ON GA1.EmployeeData(Salary) TO SalesRole;

-- Grant UPDATE permission on specific columns for ITRole
-- This allows IT to update employee information except for salary
GRANT UPDATE ON GA1.EmployeeData(FirstName, LastName, Department) TO ITRole;
DENY UPDATE ON GA1.EmployeeData(Salary) TO ITRole;
GO


-- Part 4: Testing User Access

-- EXECUTE AS: This command allows us to switch context to a different user
-- This simulates logging in as the HR Manager
EXECUTE AS USER = 'HRManagerUser';

-- HR should have full access to the employee data
SELECT *
FROM GA1.EmployeeData;

-- HR should be able to insert new employee records
INSERT INTO GA1.EmployeeData
    (EmployeeID, FirstName, LastName, Salary, Department)
VALUES
    (5, 'Eva', 'Brown', 70000.00, 'Marketing');

-- Check to see the new user is added
SELECT *
FROM GA1.EmployeeData;

-- REVERT: This command switches back to our original user context
REVERT;
GO


-- Switch to the Sales Representative user context
EXECUTE AS USER = 'SalesRepUser';

-- Sales should be able to view employee data, but not salary information
SELECT *
FROM GA1.EmployeeData;

-- This insert should fail because SalesRole only has SELECT permission
INSERT INTO GA1.EmployeeData
    (EmployeeID, FirstName, LastName, Salary, Department)
VALUES
    (6, 'Mike', 'Davis', 52000.00, 'Sales');

REVERT;
GO


-- Switch to the IT Support user context
EXECUTE AS USER = 'ITSupportUser';

-- IT should be able to view all employee data
SELECT *
FROM GA1.EmployeeData;

-- This update should succeed (updating department)
UPDATE GA1.EmployeeData SET Department = 'IT Support' WHERE EmployeeID = 3;

-- This update should fail (attempting to update salary)
UPDATE GA1.EmployeeData SET Salary = 58000.00 WHERE EmployeeID = 3;

REVERT;
GO