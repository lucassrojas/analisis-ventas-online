-- Proyecto: Análisis de Online Shopping
-- Dataset: Online Shopping Dataset
-- Link: https://www.kaggle.com/datasets/jacksondivakarr/online-shopping-dataset
-- Autor: Lucas Rojas




select top 100 * from dbo.[file]

-- Limpieza de Datos

-- Creo una copia de la tabla original, donde realizaré la limpieza. La copia contendrá solo las variables importantes para el análisis

select cast(cast(CustomerID as float) AS int) as CustomerID, Gender, Location, cast(cast(Transaction_ID as float) as int) as Transaction_ID, Transaction_Date, Product_Category, cast(cast(Quantity as float) as int) as Quantity, cast(Avg_Price AS decimal(10,2)) as Avg_Price into file2 from dbo.[file]

select top 100 * from file2

alter table file2 alter column CustomerID varchar(250) --Cambio CustomerID a texto

update file2 set CustomerID = trim(CustomerID), Gender = trim(Gender), Location = trim(Location), Product_Category = trim(Product_Category) --remover espacios en blanco de las columnas de texto

--Detecto valores nulos (31) y elimino

select * from file2 where CustomerID is null or Gender is null or Location is null or Transaction_ID is null or Transaction_Date is null or Product_Category is null or Quantity is null or Avg_Price is null

delete from file2 where CustomerID is null or Gender is null or Location is null or Transaction_ID is null or Transaction_Date is null or Product_Category is null or Quantity is null or Avg_Price is null

--Duplicados

select CustomerID,Gender,Location,Transaction_ID,Transaction_Date,Product_Category,Quantity,Avg_Price, count(*) repeticiones from file2 group by CustomerID,Gender,Location,Transaction_ID,Transaction_Date,Product_Category,Quantity,Avg_Price having count(*) > 1

with repes as (select CustomerID,Gender,Location,Transaction_ID,Transaction_Date,Product_Category,Quantity,Avg_Price, count(*) repeticiones from file2 group by CustomerID,Gender,Location,Transaction_ID,Transaction_Date,Product_Category,Quantity,Avg_Price having count(*) > 1) select sum(repeticiones - 1) from repes

-- Existen 4817 filas duplicadas, voy a eliminarlas
-- Creo una columna id

alter table file2 add id int identity(1,1)

select count(*) from file2 -- Con duplicados, se tienen 52924 registros

delete from file2 where id not in(select min(id) from file2 group by CustomerID,Gender,Location,Transaction_ID,Transaction_Date,Product_Category,Quantity,Avg_Price)

alter table file2 drop column id

select count(*) from file2 --Sin duplicados y sin nulls, se tienen 48107 registros

-- Verifico posibles nombres extraños o con errores

select Gender, count(*) from file2 group by Gender

select Location, count(*) from file2 group by Location

select Product_Category, count(*) from file2 group by Product_Category

-- No se presentan nombres extraños







-- Consultas de Métricas y KPIs

-- Revenue total

select sum(avg_price * quantity) as revenue from file2


-- Ticket Promedio

select Transaction_ID, count(*) from file2 group by Transaction_ID  -- Existen transacciones repetidas. Una sola transaccion puede ser de varios productos.

select sum(avg_price * Quantity) / count(distinct(Transaction_ID)) as ticket_promedio from file2 -- Revenue Total / Total de Ventas Únicas



-- Total de Clientes

select count(distinct CustomerID) as clientes_totales from file2



-- Unidades Vendidas

Select sum(quantity) as total_unidades_vendidas from file2


-- Revenue por mes:

-- Reviso la cantidad de años registrados

select year(Transaction_Date), count(*) from file2 group by year(transaction_date) -- Hay un solo año

-- No hay necesidad de separar por años ya que hay uno solo

select datename(month,Transaction_Date) as mes, sum(avg_price * quantity) as revenue_mes from file2 group by month(Transaction_Date),datename(month,Transaction_Date) order by month(Transaction_Date) asc


-- Top 5 Categorías por Ventas

with ventas as (select Product_Category as categoria, count(*) as ventas_categoria from file2 group by Product_Category) select top 5 *, rank() over(order by ventas_categoria desc) ranking from ventas


-- Top 5 Clientes por Revenue

with revenues as (select CustomerID, sum(Avg_Price * Quantity) as revenue_cliente from file2 group by CustomerID) select top 5 *, rank() over(order by revenue_cliente desc) ranking from revenues


-- Distribución de Ventas por Ciudad

select Location as ciudad, count(*) as ventas_ciudad from file2 group by Location

with ventas as (select Location as ciudad, COUNT(*) as ventas_ciudad from file2 group by Location) select ciudad, ventas_ciudad * 100.0 / (select count(*) as ventas_totales from file2) as porcentaje from ventas


