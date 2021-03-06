--select into VS insert select VS bulk insert 效率测试
--数据库恢复模式：简单


--Basic table
use tempdb;
GO

if(object_id('dbo.orders','U') is not NULL) drop table dbo.orders;
GO
create table dbo.orders(
orderid int not null,
orderdate date not null,
empid int not null,
custid varchar(10) not null
)

--准备基础数据（800w rows）
insert into dbo.orders 
select * from 
(values 
(10002,'20170505',1,'B'),
(10003,'20170506',2,'B'),
(10004,'20170506',1,'A'),
(10002,'20170505',1,'B'),
(10003,'20170506',2,'B'),
(10004,'20170506',1,'A')) as D(id,date,eid,cid); 

insert into dbo.orders 
select * from dbo.orders;

select count(1) from dbo.orders;--8000000

-----select into VS insert select VS bulk insert
set statistics time on;
set nocount on;
--select into
select * into tableA from dbo.orders;
/*
SQL Server 分析和编译时间: 
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 5078 毫秒，占用时间 = 5427 毫秒。
   */
--insert select
create table dbo.tableB(
orderid int not null,
orderdate date not null,
empid int not null,
custid varchar(10) not null
);
insert into tableB 
select * from dbo.orders;
/*SQL Server 分析和编译时间: 
   CPU 时间 = 0 毫秒，占用时间 = 0 毫秒。
SQL Server 分析和编译时间: 
   CPU 时间 = 2 毫秒，占用时间 = 2 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 12562 毫秒，占用时间 = 31522 毫秒。
   */
--bulk insert
create table dbo.tableC(
orderid int not null,
orderdate date not null,
empid int not null,
custid varchar(10) not null
);
bulk insert tableC 
from 'C:\CSVFile.csv'
with(
datafiletype='char',
fieldterminator=',',
rowterminator ='\n'
);
/*SQL Server 分析和编译时间: 
   CPU 时间 = 16 毫秒，占用时间 = 25 毫秒。

 SQL Server 执行时间:
   CPU 时间 = 24937 毫秒，占用时间 = 32332 毫秒。*/

--speed testing results:
--select into >> insert select >= bulk insert


drop table tableA;
drop table tableB;
drop table tableC;
drop table dbo.orders;