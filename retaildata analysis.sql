use RetailDataAnalysis


alter  table  transactions
alter  column  qty  numeric

alter table   transactions
alter  column rate  numeric

alter  table  transactions
alter column  tax  numeric



--Data Preparation And Understanding

--Q1--BEGIN 
	
	select COUNT (*) TotalNumOfRows from Customer
	select COUNT (*) TotalNumOfRows from prod_cat_info
	select COUNT (*) TotalNumOfRows from Transactions

	
--Q1--END



--Q2--BEGIN
	
	select count(total_amt)[TotalNumOfTransaction] from Transactions
	where total_amt like '-%'




--Q2--END



--Q3--BEGIN      
	
	select CONVERT(Date , DOB, 105) as Dates from Customer
	select CONVERT(Date, tran_date, 105) as Dates from Transactions




--Q3--END


--Q4--BEGIN

select DATEDIFF(Day, Min(convert(Date, tran_date,105)), Max(convert(date, tran_date,105)))[NumberOfDays],datediff(month,min(convert(date,tran_date,105)),
Max(convert(date, tran_date, 105)))[NumberOfMonths], datediff(year,min(convert(date,tran_date,105)),MAX(Convert(date,tran_date,105))) [NumberOfYears]
from Transactions



--Q4--END

--Q5--BEGIN


select* from prod_cat_info
where prod_subcat like 'DIY'

--Q5--END


--Data Analysis

--Q1--BEGIN

select top 1  Store_type, count(transaction_id) [CountofId] from Transactions
group by Store_type
order by COUNT(transaction_id) desc


--Q1--END

	
--Q2--BEGIN  
	
 select Gender, count(customer_Id) as CountOfGender from Customer
 where Gender in ('M' , 'F')
 group by Gender


--Q2--END	



--Q3--BEGIN

select top 1 city_code, count(customer_id) cust_cnt from Customer
group by city_code
order by cust_cnt desc




--Q3--END


--Q4--BEGIN
	
select count(prod_subcat) as SubCategoriesCount from prod_cat_info
where prod_cat = 'Books'
group by prod_cat





--Q4--END



--Q5--BEGIN
	
select cust_id, sum(Qty)[QuantityMax] from Transactions
group by cust_id



--Q5--END
	
--Q6--BEGIN

select  sum(total_amt) [TotalAmount] from Transactions t inner join prod_cat_info p on t.prod_cat_code = p.prod_cat_code and t.prod_subcat_code = p.prod_sub_cat_code
where prod_cat in ('BOOKS', 'ELECTRONICS')




--Q6--END

--Q7--BEGIN

select COUNT(customer_id) as CountofCustomer from Customer 
where customer_Id in ( select  cust_id from Transactions left join Customer on customer_Id = cust_id
where total_amt not like '-%' 
group by cust_id 
having count(transaction_id) > 10 )


--Q7--END


--Q8--BEGIN  

select SUM(total_amt) as amount from Transactions t inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code
and prod_sub_cat_code = prod_subcat_code
where prod_cat in ('Clothing','Electronics') and Store_type = 'Flagship Store'



--Q8--END


--Q9--BEGIN


select prod_subcat,sum(total_amt) [Total Revenue] from Customer c inner join Transactions t  on c.customer_Id= t.cust_id
inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code and t.prod_subcat_code = pci.prod_sub_cat_code
where Gender ='M' and prod_cat='Electronics'
group by prod_subcat




--Q9--END

--Q10--BEGIN

select  top 5 prod_subcat, (sum(total_amt)/(Select sum(total_amt) from Transactions))*100 as SalesPercentage,(COUNT(case when qty<0 then qty else null end)/sum(qty))*100 as PercetageOfReturn
from Transactions t
inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code and prod_subcat_code= prod_sub_cat_code
group by prod_subcat
order by sum(total_amt) desc

--Q10--END

--Q11--BEGIN


select CUST_ID,sum(TOTAL_AMT) AS TotalRevenue FROM Transactions
where CUST_ID IN (select CUSTOMER_ID FROM Customer Where datediff(year,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
AND CONVERT(DATE,tran_date,103) BETWEEN Dateadd(Day,-30,(select Max(CONVERT(date,tran_date,103)) FROM Transactions)) AND
(select MAX(convert(DATE,tran_date,103)) FROM Transactions)
Group by CUST_ID



--Q11--END


--Q12--BEGIN

select top 1 prod_cat , sum(total_amt)[TotalAmount]from Transactions t inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code
and t.prod_subcat_code = pci.prod_sub_cat_code 
where total_amt < 0 and convert (date, tran_date,103) between dateadd(month,-3,(select max(convert(date,tran_date,103)) from Transactions))
and (select max (convert(date,tran_date,103)) from Transactions)
group by prod_cat
order by [TotalAmount] desc

 --Q12--END



 --Q13--BEGIN

 select Store_type,sum(total_amt) [TotalSales], sum(Qty) [TotalQuantity] from Transactions
 group by Store_type
 having sum(total_amt) >=All  (select sum(total_amt) from Transactions group by Store_type) and 
 sum(qty) >=all (select sum(qty) from Transactions group by Store_type)


--Q13--END



--Q14--BEGIN

select prod_cat ,AVG(total_amt) as average from Transactions t inner join prod_cat_info pci on t.prod_cat_code = pci.prod_cat_code and
pci.prod_sub_cat_code = t.prod_subcat_code 
group by prod_cat
having avg(total_amt) > (select avg(total_amt) from Transactions)


--Q14--END


--Q15--BEGIN

select prod_cat,prod_subcat, avg(total_amt) [AverageRevenue],sum(total_amt) [TotalRevenue] from Transactions t
inner join prod_cat_info pci on pci.prod_cat_code = t.prod_cat_code and prod_sub_cat_code = prod_subcat_code 
where prod_cat in (select top 5 prod_cat from Transactions t1 inner join prod_cat_info pci1 on t1.prod_cat_code=pci1.prod_cat_code and prod_sub_cat_code = prod_subcat_code
group by prod_cat
order by sum(qty) desc)
group by prod_cat, prod_subcat


--Q15--END

