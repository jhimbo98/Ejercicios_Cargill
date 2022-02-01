set dateformat dmy
set language english

create table tbl_Colors(
	ColorID int not null IDENTITY(1,1),
	Color varchar(30) null,
	constraint PK_ColorID primary key (ColorID ASC),
	constraint UQ_Color unique (ColorID)
)

create table tbl_Countries(
	CountryID int not null IDENTITY(1,1),
	CountryName varchar(30) null,
	CountryISOCode char(5) not null,
	constraint PK_CountryID primary key (CountryID ASC),
	constraint UQ_CountryName unique (CountryName),
	constraint UQ_CountryISOCode unique (CountryISOCode)
)

create table tbl_Clients(
	ClientID int not null IDENTITY(1,1),
	ClientName varchar(40) not null,
	Address1 varchar(255) null,
	Address2 varchar(255) null,
	Town varchar(30) null,
	County varchar(30) null,
	PostCode varchar(30) null,
	Region varchar(50) null,
	OuterPostCode char(5) null,
	CountryID int not null,
	ClientType varchar(15) null,
	ClientSize varchar(15) null,
	ClientSince smalldatetime,
	IsCreditWorthy bit null,
	IsDealer bit null,
	constraint PK_ClientID primary key (ClientID ASC),
	constraint FK_CountryID foreign key (CountryID) references tbl_Countries(CountryID),
	constraint CH_ClientType check (ClientType in ('Wholesaler', 'Dealer')),
	constraint CH_ClientSize check (ClientSize in ('Large', 'Small')),
	
)


create table tbl_Stock(
	StockID int not null IDENTITY(1,1),
	Make varchar(35) not null,
	Model varchar(255) not null,
	ColorID int not null,
	VehicleType varchar(30) not null,
	CostPrice int not null,
	SpareParts smallint not null,
	LaborCost smallint not null,
	Registration_Date date not null default GETDATE() ,
	Mileage int not null,
	PurchaseDate date null,
	VehicleAgeInYears tinyint not null,
	constraint PK_StockID primary key (StockID ASC),
	constraint FK_ColorID foreign key (ColorID) references tbl_Colors(ColorID),
	constraint CH_CostPrice check (CostPrice > 0),
	constraint CH_SpareParts check (SpareParts > 0),
	constraint CH_LaborCost check (LaborCost > 0),
	constraint CH_Mileage check (Mileage > 0),
	constraint CH_VehicleAgeInYears check (VehicleAgeInYears > 0),
	
)

set dateformat ymd



create table tbl_Invoices(
	InvoiceID int not null IDENTITY(1,1),
	InvoiceNumber varchar(50) not null,
	ClientID int not null,
	InvoiceDate smalldatetime not null default SYSDATETIMEOFFSET(), /*El campo llamado InvoiceDate existe una confusión generada por el hecho de que los datos que se encuentran en este campo son de tipo time por ende no cumple que sea de tipo date tal cual el nombre del campo lo indica*/
	TotalDiscount varchar(5) default 0,
	DeliveryCharge smallint default 0,
	InvoiceDateKey date not null default GETDATE(),
	constraint PK_InvoiceID primary key (InvoiceID ASC),
	constraint FK_ClientID foreign key (ClientID) references tbl_Clients(ClientID),
	constraint CH_TotalDiscount check (TotalDiscount >= 0),
	constraint CH_DeliveryCharge check (DeliveryCharge >= 0),
	
)

create table tbl_InvoiceLines(
	InvoiceLineID int not null IDENTITY(3,1),
	InvoiceID int not null,
	StockID int not null,
	SalePrice int not null,
	LineItem tinyint not null,
	constraint PK_InvoiceLineID primary key (InvoiceLineID ASC),
	constraint FK_InvoiceID foreign key (InvoiceID) references tbl_Invoices(InvoiceID),
	constraint FK_StockID foreign key (StockID) references tbl_Stock(StockID),
	constraint CH_SalePrice check (SalePrice > 0),
		
)


/*INSERT DE TABLA COLORS*/
BULK INSERT [dbo].[tbl_Colors]
from 'D:\Jhimley M\Downloads\Colors_CarSalesDataForReports.csv'
with (
     FIELDTERMINATOR=';',
	 ROWTERMINATOR='\n',
	 FIRSTROW=2
)

select * from tbl_colors 
go

/*INSERT DE TABLA COUNTRIES*/
BULK INSERT [dbo].[tbl_Countries]
from 'D:\Jhimley M\Downloads\Countries_CarSalesDataForReports.csv'
with (
     FIELDTERMINATOR=';',
	 ROWTERMINATOR='\n',
	 FIRSTROW=2
)

select * from [dbo].[tbl_Countries]
go

/*INSERT DE TABLA CLIENTS*/
BULK INSERT [dbo].[tbl_Clients]
from 'D:\Jhimley M\Downloads\Clients_CarSalesDataForReports.csv'
with (
     FIELDTERMINATOR=';',
	 ROWTERMINATOR='\n',
	 FIRSTROW=2
)

select * from [dbo].[tbl_Clients]
go

/*INSERT DE TABLA STOCK*/
BULK INSERT [dbo].[tbl_Stock]
from 'D:\Jhimley M\Downloads\Stock_CarSalesDataForReports.csv'
with (
     FIELDTERMINATOR=';',
	 ROWTERMINATOR='\n',
	 FIRSTROW=2
)

select * from [dbo].[tbl_Stock]
go

/*INSERT DE TABLA INVOICES*/
BULK INSERT [dbo].[tbl_Invoices]
from 'D:\Jhimley M\Downloads\Invoices_CarSalesDataForReports.csv'
with (
     FIELDTERMINATOR=';',
	 ROWTERMINATOR='\n',
	 FIRSTROW=2
)

select * from [dbo].[tbl_Invoices]
go

/*INSERT DE TABLA INVOICELINES*/
BULK INSERT [dbo].[tbl_InvoiceLines]
from 'D:\Jhimley M\Downloads\InvoiceLines_CarSalesDataForReports.csv'
with (
     FIELDTERMINATOR=';',
	 ROWTERMINATOR='\n',
	 FIRSTROW=2
)

select * from [dbo].[tbl_InvoiceLines]
go

select * from [dbo].[tbl_InvoiceLines]
select * from [dbo].[tbl_Stock]
select * from [dbo].[tbl_Invoices]
go

select CONVERT(char(10),[InvoiceDate],103) as InvoiceDate from [dbo].[tbl_Invoices]
where not (InvoiceDate between '01/04/2015' and '30/06/2015') and year(InvoiceDate) = '2015'
union
select CONVERT(char(10),[InvoiceDate],103) as InvoiceDate from [dbo].[tbl_Invoices]
where not (InvoiceDate between '01/10/2015' and '31/12/2015') and year(InvoiceDate) = '2015'


go
select * from (
	select * from (
		select DATEPART(q,InvoiceDate) as Quarters,[SalePrice],[Make],[Model], CONVERT(char(10),[InvoiceDate],103) as InvoiceDate,
		row_number() OVER (Order by SalePrice DESC) as TopSalePrice
		from [dbo].[tbl_InvoiceLines] IL
		inner join [dbo].[tbl_Invoices] I on IL.[InvoiceID] = I.InvoiceID
		inner join [dbo].[tbl_Stock] S on IL.StockID = S.StockID
		where year(InvoiceDate) = '2015'  and MONTH(InvoiceDate)<4 

	) AS T
	Union
	select DATEPART(q,InvoiceDate) as Quarters,[SalePrice],[Make],[Model], CONVERT(char(10),[InvoiceDate],103) as InvoiceDate,
		row_number() OVER (Order by SalePrice DESC) as TopSalePrice
		from [dbo].[tbl_InvoiceLines] IL
		inner join [dbo].[tbl_Invoices] I on IL.[InvoiceID] = I.InvoiceID
		inner join [dbo].[tbl_Stock] S on IL.StockID = S.StockID
		where year(InvoiceDate) = '2015'  and Month(InvoiceDate) between 7 and 9
) AS Y
where TopSalePrice <=3
order by Datepart(q,InvoiceDate), TopSalePrice ASC
go

select * from (
	select * from (
		select * from (
			select * from (
				select DATEPART(q,InvoiceDate) as Quarters,[SalePrice],[Make],[Model], CONVERT(char(10),[InvoiceDate],103) as InvoiceDate,
						row_number() OVER (Order by SalePrice DESC) as TopSalePrice, C.Color
						from [dbo].[tbl_InvoiceLines] IL
						inner join [dbo].[tbl_Invoices] I on IL.[InvoiceID] = I.InvoiceID
						inner join [dbo].[tbl_Stock] S on IL.StockID = S.StockID
						inner join tbl_Colors C on C.ColorID = S.ColorID
						where year(InvoiceDate) = '2012'   
				) as T
					Union
					select DATEPART(q,InvoiceDate) as Quarters,[SalePrice],[Make],[Model], CONVERT(char(10),[InvoiceDate],103) as InvoiceDate,
							row_number() OVER (Order by SalePrice DESC) as TopSalePrice, C.Color
							from [dbo].[tbl_InvoiceLines] IL
							inner join [dbo].[tbl_Invoices] I on IL.[InvoiceID] = I.InvoiceID
							inner join [dbo].[tbl_Stock] S on IL.StockID = S.StockID
							inner join tbl_Colors C on C.ColorID = S.ColorID
							where year(InvoiceDate) = '2013' 
			)as Y
			Union
					select DATEPART(q,InvoiceDate) as Quarters,[SalePrice],[Make],[Model], CONVERT(char(10),[InvoiceDate],103) as InvoiceDate,
							row_number() OVER (Order by SalePrice DESC) as TopSalePrice, C.Color
							from [dbo].[tbl_InvoiceLines] IL
							inner join [dbo].[tbl_Invoices] I on IL.[InvoiceID] = I.InvoiceID
							inner join [dbo].[tbl_Stock] S on IL.StockID = S.StockID
							inner join tbl_Colors C on C.ColorID = S.ColorID
							where year(InvoiceDate) = '2014' 
	)as Z
			Union
					select DATEPART(q,InvoiceDate) as Quarters,[SalePrice],[Make],[Model], CONVERT(char(10),[InvoiceDate],103) as InvoiceDate,
							row_number() OVER (Order by SalePrice DESC) as TopSalePrice, C.Color 
							from [dbo].[tbl_InvoiceLines] IL
							inner join [dbo].[tbl_Invoices] I on IL.[InvoiceID] = I.InvoiceID
							inner join [dbo].[tbl_Stock] S on IL.StockID = S.StockID
							inner join tbl_Colors C on C.ColorID = S.ColorID
							where year(InvoiceDate) = '2015'
							
							
)as W
where TopSalePrice <= 3
order by TopSalePrice, year(InvoiceDate)