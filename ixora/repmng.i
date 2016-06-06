/* repmng.i
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Первоначальное заполнение таблицы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        12.18
 * AUTHOR
        14/12/2010 madiyar
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1182,1258,1257,1650. добавил lonrp18,londother,intother;Other (manual adjustment) убрал (manual adjustment).
*/

procedure kritCreate.
    def input parameter p-i as integer no-undo.
    def input parameter p-kcode as char no-undo.
    def input parameter p-des1 as char no-undo.
    def input parameter p-des2 as char no-undo.
    def input parameter p-level as integer no-undo.
    def input parameter p-bold-code as log no-undo.
    def input parameter p-color-code as log no-undo.
    create t-krit.
    assign t-krit.kid = p-i
           t-krit.kcode = p-kcode
           t-krit.bold_code = p-bold-code
           t-krit.color_code = p-color-code
           t-krit.des_en = p-des1
           t-krit.des_ru = p-des2
           t-krit.level = p-level.
end procedure.

i = 1. run kritCreate(i,"-","B/S","",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"cash","Cash and equivalents","Касса",1,yes,no).
i = i + 1. run kritCreate(i,"dueBanks","Due from banks","дебиторы по документарным операциям",1,yes,no).

i = i + 1. run kritCreate(i,"lon","Net loans","Итого кредиты",1,yes,no).
i = i + 1. run kritCreate(i,"lonr","Retail loans net","Итого розница ФЛ",2,yes,no).
i = i + 1. run kritCreate(i,"lonr1","Upto 1 year","До 1 года",3,no,no).
i = i + 1. run kritCreate(i,"lonr2","Between 1 and 3 years","От 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"lonr3","Over 3 years","Свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"lonri","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"lonro30","Overdue credits (over 30 days)","Просроченные кредиты (свыше 30 дней)",3,no,no).
i = i + 1. run kritCreate(i,"lonrio","% overdue interest","% вознаграждение просроченное",3,no,no).
i = i + 1. run kritCreate(i,"lonrp","Provisions specific","Провизии",3,no,no).
i = i + 1. run kritCreate(i,"lons","SME loans net","Итого МСБ кредиты",2,yes,no).
i = i + 1. run kritCreate(i,"lons1","Upto 1 year","До 1 года",3,no,no).
i = i + 1. run kritCreate(i,"lons2","Between 1 and 3 years","От 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"lons3","Over 3 years","Свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"lonsi","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"lonso30","Overdue credits (over 30 days)","Просроченные кредиты (свыше 30 дней)",3,no,no).
i = i + 1. run kritCreate(i,"lonsio","% overdue interest","% вознаграждение просроченное",3,no,no).
i = i + 1. run kritCreate(i,"lonsp","Provisions specific","Провизии",3,no,no).
i = i + 1. run kritCreate(i,"lonc","Corporate loans net","Итого корпоративные клиенты ЮЛ",2,yes,no).
i = i + 1. run kritCreate(i,"lonc1","Upto 1 year","До 1 года",3,no,no).
i = i + 1. run kritCreate(i,"lonc2","Between 1 and 3 years","От 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"lonc3","Over 3 years","Свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"lonci","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"lonco30","Overdue credits (over 30 days)","Просроченные кредиты (свыше 30 дней)",3,no,no).
i = i + 1. run kritCreate(i,"loncio","% overdue interest","% вознаграждение просроченное",3,no,no).
i = i + 1. run kritCreate(i,"loncp","Provisions specific","Провизии",3,no,no).
i = i + 1. run kritCreate(i,"lonrp18","Discount","Дисконт по займам",2,yes,no).
i = i + 1. run kritCreate(i,"lonprov","Provisions general","Общие провизии",2,yes,no).
i = i + 1. run kritCreate(i,"lonast","Fixed assets","Основные средства",2,yes,no).
i = i + 1. run kritCreate(i,"assets_other","Other assets","Прочие активы",1,yes,no).
i = i + 1. run kritCreate(i,"assets_total","Total Assets","Итого Активы",1,yes,yes).


i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"depo","Deposits","Депозиты",1,yes,no).
i = i + 1. run kritCreate(i,"depor","Retail total","итого Розница ФЛ",2,yes,no).
i = i + 1. run kritCreate(i,"depov","Demand","до востребования", 3,no,no).
i = i + 1. run kritCreate(i,"depov1","Upto 1 year","до 1 года",3,no,no).
i = i + 1. run kritCreate(i,"depov2","Between 1 and 3 years","от 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depov3","Over 3 years","свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depov%","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"depoSM","SME total","итого МСБ",2,yes,no).
i = i + 1. run kritCreate(i,"depoSMv","Demand","до востребования",3,no,no).
i = i + 1. run kritCreate(i,"depoSM1","Upto 1 year","до 1 года",3,no,no).
i = i + 1. run kritCreate(i,"depoSM2","Between 1 and 3 years","от 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depoSM3","Over 3 years","свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depoSM%","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP","Corporate total","",2,yes,no).
i = i + 1. run kritCreate(i,"depoCORPv","Demand","до востребования",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP1","Upto 1 year","до 1 года",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP2","Between 1 and 3 years","от 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP3","Over 3 years","свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP%","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"depoGAR","Other deposits (guarantees, etc)","прочие депозиты (гарантии)",2,yes,no).

i = i + 1. run kritCreate(i,"docSetCredit","Documentary settlements creditors","Кредиторы по документарным расчетам",1,yes,no).

i = i + 1. run kritCreate(i,"obiazPROCHIE","Other liabilities","Прочие обязательства",1,yes,no).
i = i + 1. run kritCreate(i,"itogo_obiazatelstva","Total Liabilities ","Итого обязательства ",1,yes,yes).


i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"CAPITAL","Equity allocation","распределение капитала",1,yes,no).
i = i + 1. run kritCreate(i,"capitalALL","Total Liabilities & Equity allocation","итого Обязательства & распределение капитала",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"zaimSO","Borrowings from HO (Lendings to HO)","заимствования от ЦО",1,no,no).

i = i + 1. run kritCreate(i,"zaim","Demand","до востребования",2,no,no).
i = i + 1. run kritCreate(i,"zaim1","Upto 1 year","до 1 года",2,no,no).
i = i + 1. run kritCreate(i,"zaim2","Between 1 and 3 years","от 1 до 3 лет",2,no,no).
i = i + 1. run kritCreate(i,"zaim3","Over 3 years","свыше 3 лет",2,no,no).
i = i + 1. run kritCreate(i,"zaim4","Without term","без срока",2,no,no).
i = i + 1. run kritCreate(i,"zaimItogo","Total borrowings (lendings)","Итого заимствования",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"-","P&L","",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"londoh","Interest income","Процентные доходы",1,yes,yes).
i = i + 1. run kritCreate(i,"londoh_r","Retail","Розница ФЛ",2,no,no).
i = i + 1. run kritCreate(i,"londoh_s","SME","МСБ",2,no,no).
i = i + 1. run kritCreate(i,"londoh_c","Corporate","Корпоративные клиенты",2,no,no).
i = i + 1. run kritCreate(i,"londother","Other","Other (manual adjustment)",2,no,no).
i = i + 1. run kritCreate(i,"londHO","HO","Центральный офис",2,no,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"intRash","Interest expense","Процентные расходы",1,yes,yes).
i = i + 1. run kritCreate(i,"intRozn","Retail","Розница ФЛ",2,no,no).
i = i + 1. run kritCreate(i,"intMsb","SME","МСБ",2,no,no).
i = i + 1. run kritCreate(i,"intCorporate","Corporate","Корпоративные клиенты ЮЛ",2,no,no).
i = i + 1. run kritCreate(i,"intother","Other","Other (manual adjustment)",2,no,no).
i = i + 1. run kritCreate(i,"intHO","HO","Центральный офис",2,no,no).
i = i + 1. run kritCreate(i,"com_capcost","Capital cost","Себестоимость капитала",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"net_incom","Net interest income","Чистый процентный доход",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

/* id00205*/
i = i + 1. run kritCreate(i,"com_incom","Commission income","Комиссионные доходы",1,yes,no).
i = i + 1. run kritCreate(i,"com_incom1","Retail","Розница ФЛ",2,no,no).
i = i + 1. run kritCreate(i,"com_incom2","SME","МСБ",2,no,no).
i = i + 1. run kritCreate(i,"com_incom3","Corporate","Корпоративные клиенты ЮЛ",2,no,no).
/*i = i + 1. run kritCreate(i,"com_incom4","HO","Центральный офис",2,no,no).*/
i = i + 1. run kritCreate(i,"com_exp","Commission expense","Комиссионные расходы",1,yes,no).

/*i = i + 1. run kritCreate(i,"com_other1003","Other","по тз 1003",1,yes,no).*/
i = i + 1. run kritCreate(i,"com_FXincome1003","FX income","по тз 1003",1,yes,no).
i = i + 1. run kritCreate(i,"com_FXexpense1003","FX expense","по тз 1003",1,yes,no).
i = i + 1. run kritCreate(i,"com_NetCommFXincome1003","Net Commission/FX income","по тз 1003",1,yes,yes).

/*i = i + 1. run kritCreate(i,"com_incom_all","Net commission income","Итого комиссионный доход",1,yes,yes).*/

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_inexp","Other","Нетто прочие доходы/расходы",1,no,no).
/*i = i + 1. run kritCreate(i,"com_inexp","Net other incomes/expenses","Нетто прочие доходы/расходы",1,no,no).*/
/*i = i + 1. run kritCreate(i,"com_inexp_val","Net incomes/expenses of foreign currency revaluation of assets and liabilities","Нетто доходы/расходы от переоценки валюты",1,no,no).*/

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_socpay","Salaries and social payments","Зарплата и социальные платежи",2,yes,no).
i = i + 1. run kritCreate(i,"com_bon","Bonuses and other payments","Бонусы",2,yes,no).
i = i + 1. run kritCreate(i,"com_trip","Business trips","Служебные командировки",2,yes,no).
i = i + 1. run kritCreate(i,"com_renpay","Rent & communal payments","Аренда и коммунальные платежи",2,yes,no).
i = i + 1. run kritCreate(i,"com_amort","Amortisation","Амортизационные отчисления",2,yes,no).
i = i + 1. run kritCreate(i,"com_taxgov","Taxes and other gov obligations","Налоги и другие обяз. платежи в бюджет",2,yes,no).
i = i + 1. run kritCreate(i,"com_call","Communication expenses","Расходы по услугам связи",2,yes,no).
i = i + 1. run kritCreate(i,"com_mark","Marketing","Расходы на рекламу и маркетинг",2,yes,no).
i = i + 1. run kritCreate(i,"com_secur","Security expenses","Расходы на охрану и сигнализацию",2,yes,no).
i = i + 1. run kritCreate(i,"com_admin","Administrative expenses","Административные расходы",2,yes,no).
i = i + 1. run kritCreate(i,"com_other","Other operating expenses","Прочие расходы",2,yes,no).
i = i + 1. run kritCreate(i,"com_exp_all","Total operating expenses","Итого операционные расходы",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_operexp","HO operating expenses allocation","распределение расходов ЦО на филиалы",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_braincom","Branch operating income (pre provisions)","Опер. доход филиала (до провизий, до расходов ЦО)",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_prov","Provision expense","Провизии",1,yes,yes).
i = i + 1. run kritCreate(i,"com_prov1","Provisions formed","Ассигнования на резервы",2,no,no).
i = i + 1. run kritCreate(i,"com_prov2","Provisions returned","Доход от восстановления резервов",2,no,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_precost","Branch operating income (post provisions)","Операционный доход филиала (без расходов ЦО)",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).


/*i = i + 1. run kritCreate(i,"com_postcost","Branch operating income (pre HO cost)","Опер. доход филиала (с учетом расходов ЦО)",1,yes,no).*/


/*i = i + 1. run kritCreate(i,"com_capcost","Capital cost","Себестоимость капитала",1,yes,no).*/

/*i = i + 1. run kritCreate(i,"-","","",1,no,no).*/

/*
i = i + 1. run kritCreate(i,"com_boiall","Branch operating income (BOI)","Итого операционный доход филиала",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).
*/

i = i + 1. run kritCreate(i,"-","Off B/S Items","",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"lc","L/C's","Аккредитивы",1,no,no).
i = i + 1. run kritCreate(i,"lg","L/G's","Гарантии",1,no,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"openfx","Open FX position","Открытая валютная позиция",1,no,no).

  for each crc where crc.crc <> 5 no-lock.
    i = i + 1. run kritCreate(i,"openfx" + string(crc.crc),crc.code,crc.des,2,no,no).
  end.

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"-","End","",1,yes,no).

/* end id00205*/




