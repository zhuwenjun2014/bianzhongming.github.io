--------------VIEW DEMO
-------BASIC
IF OBJECT_ID('dbo.vw_usacus') is not null
 drop view dbo.vw_usacus;
go
create view dbo.vw_usacus 
as 
SELECT custid id, companyname name
FROM InsideTSQL.Sales.Customers
where country='USA';
GO

select * from vw_usacus;

-------内联别名
IF OBJECT_ID('dbo.vw_usacus') is not null
 drop view dbo.vw_usacus;
go
create view dbo.vw_usacus(id,name) 
as 
SELECT custid, companyname
FROM InsideTSQL.Sales.Customers
where country='USA';
GO

select * from vw_usacus;

--视图的存储（编译存储）
IF OBJECT_ID('dbo.vw_usacus') is not null
 drop view dbo.vw_usacus;
go
create view dbo.vw_usacus 
as 
SELECT *
FROM InsideTSQL.Sales.Customers
where country='USA';
GO

select * from vw_usacus;

alter table InsideTSQL.Sales.Customers add test int null ;

select test from InsideTSQL.Sales.Customers;
select test from vw_usacus; --Lookup Error - SQL Server Database Error: Invalid column name 'test'.

sp_refreshview vw_usacus;  --刷新视图定义

select test from vw_usacus;

alter table InsideTSQL.Sales.Customers drop column test ;
select test from InsideTSQL.Sales.Customers; --Lookup Error - SQL Server Database Error: Invalid column name 'test'.
select test from vw_usacus; --Lookup Error - SQL Server Database Error: View or function 'vw_usacus' has more column names specified than columns defined.

sp_refreshview vw_usacus; 
select test from vw_usacus; --Lookup Error - SQL Server Database Error: Invalid column name 'test'.

/*
视图中指名列名，避免select *。变更的列不会自动更新到视图中。
视图的存储：select *->视图编译：对应列名->存储
*/

-------视图的数据操作测试
if(object_id('dbo.testa') is not null) drop table testa;
 GO
create table testa (id bigint not null primary key identity(1,1),tname varchar(20) NULL,tname2 varchar(20) NULL);

insert into testa (tname,tname2) values(N'XXXXXXX',N'XXXXXXX'),(N'YYYYYYYYYY',N'YYYYYYYYYY'),(N'ZZZZZZZZZZ',N'ZZZZZZZZZZ'); 

select * from testa;

create view testa as select id,tname from testa;
--Lookup Error - SQL Server Database Error: There is already an object named 'testa' in the database.
--VIEW和table一样，都属于object，重名会报错。

--view命名规范
if(object_id('dbo.vw_testa') is not null) drop view vw_testa;
go
create view vw_testa as select id,tname from testa; 
GO
select * from vw_testa;

update vw_testa set tname='1111111' where id=1;

update vw_testa set tname2='1111111' where id=1;
--Lookup Error - SQL Server Database Error: Invalid column name 'tname2'.
--只能更新引用数据列

select * from testa;

-------视图选项测试
--ENCRYPTION （加密）:
--范围：VIEW/PROCDURE/FUNCTION/TRIGGER
--查看视图定义
select object_definition(object_id('vw_testa')); --换行符存储在单元格内
sp_helptext 'vw_testa'; --分行显示
--create view vw_testa as select id,tname from testa;
/*
select object_definition(object_id('dbo.ClearZero'));--VIEW/PROCDURE/FUNCTION/TRIGGER
sp_helptext 'dbo.ClearZero'; --VIEW/PROCDURE/FUNCTION/TRIGGER
*/

alter view vw_testa with encryption
as select id,tname from testa;

select object_definition(object_id('vw_testa'));--NULL
sp_helptext 'vw_testa'; --15471:sp_helptext:113: The text for object 'vw_testa' is encrypted.

--schemabinding
--范围：视图，UDF（用户定义函数）
--条件：指名column，from对象二段命名方式（schema.tablename）
alter view vw_testa with schemabinding
as select id,tname from dbo.testa; --from的对象名必须包含架构

select * from vw_testa ;
alter table testa drop column tname2;--Executed Successfully
alter table testa drop column tname;
--Lookup Error - SQL Server Database Error: The object 'vw_testa' is dependent on column 'tname'.

--check option
insert into testa (tname,tname2) values(N'XXXXXXX',N'XXXXXXX'),(N'XXXXXXX',N'XXXXXXX'),(N'XXXXXXX',N'XXXXXXX')

alter view vw_testa with schemabinding
as select id,tname from dbo.testa where tname =N'XXXXXXX';

update vw_testa set tname='NNNN' where id=1;
--只能变更view结果集内的数据
select * from vw_testa;
select * from testa;

insert into vw_testa(tname) values(N'BBBBBBBB')
select * from vw_testa; --结果集不变，插入之后的数据被视图的查询条件过滤掉了
select * from testa;--7	BBBBBBBB	

alter view vw_testa with schemabinding
as 
select id,tname 
from dbo.testa 
where tname =N'XXXXXXX'
with check option;

insert into vw_testa(tname) values(N'BBBBBBBB');
-- SQL Server Database Error: The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
update vw_testa set tname='' 
-- SQL Server Database Error: The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.

drop view vw_testa;
drop table testa;

