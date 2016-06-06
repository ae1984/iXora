/* repmng_ho.i
 * MODULE
        Управленческая отчетность
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
        Пункт меню
 * AUTHOR
        14/12/2010 madiyar
 * CHANGES
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
i = i + 1. run kritCreate(i,"dueNBRK","Due from NBRK","",1,yes,no).
i = i + 1. run kritCreate(i,"nbrkCorr","Correspondent accounts","Корреспондентский счет в НБ РК",2,no,no).
i = i + 1. run kritCreate(i,"nbrkDep","Deposits","Вклады в НБ РК",2,no,no).
i = i + 1. run kritCreate(i,"dueBanks","Due from banks","",1,yes,no).

i = i + 1. run kritCreate(i,"secur","Securities portfolio","Портфель ценных бумаг",1,yes,no).
i = i + 1. run kritCreate(i,"securTrade","Trading portfolio","Портфель торговых ценных бумаг",2,no,no).
i = i + 1. run kritCreate(i,"securInvest","Investment portfolio","Инвестиционный портфель",2,no,no).
i = i + 1. run kritCreate(i,"securREPO","REPO agreements","Ценные бумаги по договору обратного РЕПО",2,no,no).

i = i + 1. run kritCreate(i,"lon","Net loans","Итого кредиты",1,yes,no).
i = i + 1. run kritCreate(i,"lonr","Retail loans net","Итого розница",2,yes,no).
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

i = i + 1. run kritCreate(i,"SO_lon","Loans (booked at HO)","Итого кредиты (ЦО)",2,yes,no).

i = i + 1. run kritCreate(i,"SO_lonr1","Upto 1 year","До 1 года",3,no,no).
i = i + 1. run kritCreate(i,"SO_lonr2","Between 1 and 3 years","От 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"SO_lonr3","Over 3 years","Свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"SO_lonri","% interest","% вознаграждение текущее",3,no,no).
i = i + 1. run kritCreate(i,"SO_lonro30","Overdue credits (over 30 days)","Просроченные кредиты (свыше 30 дней)",3,no,no).
i = i + 1. run kritCreate(i,"SO_lonrio","% overdue interest","% вознаграждение просроченное",3,no,no).
i = i + 1. run kritCreate(i,"SO_lonrp","Provisions specific","Провизии",3,no,no).
i = i + 1. run kritCreate(i,"lonrp18","Discount","Discount",2,no,no).

i = i + 1. run kritCreate(i,"lonprov","Provisions general","Общие провизии",2,yes,no).

i = i + 1. run kritCreate(i,"lonast","Property and equipment","Основные средства",1,yes,no).
i = i + 1. run kritCreate(i,"astSoft","Goodwill, software and other intangible assets","Нематериальные активы",1,yes,no).
i = i + 1. run kritCreate(i,"taxAst","Deferred tax assets","Отсроченное налоговое требование",1,yes,no).
i = i + 1. run kritCreate(i,"assets_other","Other assets","Прочие активы",1,yes,no).
i = i + 1. run kritCreate(i,"assets_total","Total Assets","Итого активов",1,yes,yes).


i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"SO_dueToBanks","Due to banks","",1,yes,no).
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
i = i + 1. run kritCreate(i,"depoCORP","Corporate total","Итого корпоротивные клиенты ЮЛ",2,yes,no).
i = i + 1. run kritCreate(i,"depoCORPv","Demand","до востребования",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP1","Upto 1 year","до 1 года",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP2","Between 1 and 3 years","от 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP3","Over 3 years","свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"depoCORP%","% interest","% вознаграждение текущее",3,no,no).

i = i + 1. run kritCreate(i,"SO_depo","Deposits (booked at HO)","Депозиты (ЦО)",2,yes,no).
i = i + 1. run kritCreate(i,"SO_depov","Demand","до востребования", 3,no,no).
i = i + 1. run kritCreate(i,"SO_depov1","Upto 1 year","до 1 года",3,no,no).
i = i + 1. run kritCreate(i,"SO_depov2","Between 1 and 3 years","от 1 до 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"SO_depov3","Over 3 years","свыше 3 лет",3,no,no).
i = i + 1. run kritCreate(i,"SO_depov%","% interest","% вознаграждение текущее",3,no,no).

i = i + 1. run kritCreate(i,"depoGAR","Other deposits (guarantees, etc)","прочие депозиты (гарантии)",2,yes,no).
i = i + 1. run kritCreate(i,"SO_privlSr","Other borrowed funds","Прочие привлеченные средства",1,yes,no).
i = i + 1. run kritCreate(i,"SO_dolgObiaz","Debt securities issued","Выпущенные долговые ценные бумаги",1,yes,no).
i = i + 1. run kritCreate(i,"SO_nalogObiaz","Deferred tax liabilities","Отсроченное налоговое обязательство",1,yes,no).

i = i + 1. run kritCreate(i,"docSetCredit","Documentary settlements creditors","Кредиторы по документарным расчетам",1,yes,no).

i = i + 1. run kritCreate(i,"SO_prochieObiaz","Other liabilities","Прочие обязательства",1,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"SO_subordDolg","Subbordinated debt","Субординированный долг",1,yes,no).
i = i + 1. run kritCreate(i,"SO_obiazatelstva","Total Liabilities (incl. subordinated debt)","Итого обязательства (в т.ч. Субординированный долг)",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"SO_ustkapital","Shareholders equity","Уставный капитал",1,yes,no).
i = i + 1. run kritCreate(i,"SO_Aksion_capital","Ordinary share capital","Простой акционерный капитал",2,no,no).
i = i + 1. run kritCreate(i,"SO_Privelig_capital","Preference share capital","Привилегированный акционерный капитал",2,no,no).

i = i + 1. run kritCreate(i,"SO_Adjust_provision_account","Provisions adjustment account","Adjusted provision account",2,no,no). /*TZ1120*/


i = i + 1. run kritCreate(i,"SO_Reserve","Revaluation reserve","Резервы переоценки",2,no,no).
i = i + 1. run kritCreate(i,"SO_Ner_dohod_pred","Retained earnings (previous period)","Нераспределенный доход(предыдущий период)",2,no,no).
i = i + 1. run kritCreate(i,"SO_Ner_dohod_tekuch","Retained earnings (current period)","Нераспределенный доход(текущий период)",2,no,no).

i = i + 1. run kritCreate(i,"SO_Net_profit_loss","Net profit/loss","Net profit/loss",2,no,no). /*TZ1120*/
i = i + 1. run kritCreate(i,"SO_Retained_earnings","Retained earnings – provisions","Retained earnings – provisions",2,no,no). /*TZ1120*/


i = i + 1. run kritCreate(i,"SO_Ner_other_reserve","Other reserves","Прочие резервы)",2,no,no).

i = i + 1. run kritCreate(i,"SO_itoge_obiaz","Total Liabilities & Shareholders equity","Итого Обязательства и капитал Акционеров)",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"-","P&L","",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"londoh","Interest income","Процентные доходы",1,yes,yes).
i = i + 1. run kritCreate(i,"londoh_banks","Due from other banks","По займам выданным банкам",2,yes,no).
i = i + 1. run kritCreate(i,"londoh_clients","Loans and advances to customers","По займам, предоставленным клиентам",2,yes,no).
i = i + 1. run kritCreate(i,"londoh_r","Retail","Розница ФЛ",3,no,no).
i = i + 1. run kritCreate(i,"londoh_s","SME","МСБ",3,no,no).
i = i + 1. run kritCreate(i,"londoh_c","Corporate","Корпоративные клиенты",3,no,no).
i = i + 1. run kritCreate(i,"londHO","HO","Центральный офис",3,no,no).
i = i + 1. run kritCreate(i,"londoh_secur","Securities","Ценные бумаги",2,yes,no).
i = i + 1. run kritCreate(i,"londoh_other","Other","Прочие доходы",2,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"SO_rashod","Interest expense","Процентные расходы",1,yes,yes).
i = i + 1. run kritCreate(i,"SO_rashod_deposit","Customer deposits","Депозиты клиентов",2,yes,no).
i = i + 1. run kritCreate(i,"SO_londoh_r","Retail","Розница ФЛ",3,no,no).
i = i + 1. run kritCreate(i,"SO_londoh_s","SME","МСБ",3,no,no).
i = i + 1. run kritCreate(i,"SO_londoh_c","Corporate","Корпоративные клиенты",3,no,no).
i = i + 1. run kritCreate(i,"SO_londHO","HO","Центральный офис",3,no,no).
i = i + 1. run kritCreate(i,"SO_rashod_bank","Due to banks and other issued funds","Связанные с выплатой вознаграждения по вкладам других банков",2,yes,no).

/*i = i + 1. run kritCreate(i,"SO_rashod_sen","Debt securities issued","по выпущенным долговым ценным бумагам",2,no,no).*/
i = i + 1. run kritCreate(i,"SO_rashod_sen","Securities","по выпущенным долговым ценным бумагам",2,yes,no).

i = i + 1. run kritCreate(i,"SO_rashod_subDolg","Subbordinated debt","Субординированный долг",2,yes,no).
i = i + 1. run kritCreate(i,"SO_pref_shares","Preference shares","Остаток по ГК 5926",2,yes,no).
i = i + 1. run kritCreate(i,"SO_rashod_prochie","Other","Прочие расходы",2,yes,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"net_incom","Net interest income","Чистый процентный доход",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_incom","Commission income","Комиссионные доходы",1,yes,no).
i = i + 1. run kritCreate(i,"com_incom1","Retail","Розница ФЛ",2,no,no).
i = i + 1. run kritCreate(i,"com_incom2","SME","МСБ",2,no,no).
i = i + 1. run kritCreate(i,"com_incom3","Corporate","Корпоративные клиенты ЮЛ",2,no,no).
i = i + 1. run kritCreate(i,"SO_com_incom","HO","ЦО",2,no,no).
i = i + 1. run kritCreate(i,"com_exp","Commission expense","Комиссионные расходы",1,yes,no).

/*i = i + 1. run kritCreate(i,"com_other1003","Other","по тз 1003",1,yes,no).*/
i = i + 1. run kritCreate(i,"com_FXincome1003","FX income","по тз 1003",1,yes,no).
i = i + 1. run kritCreate(i,"com_FXexpense1003","FX expense","по тз 1003",1,yes,no).
i = i + 1. run kritCreate(i,"com_NetCommFXincome1003","Net Commission/FX income","по тз 1003",1,yes,yes).

/*i = i + 1. run kritCreate(i,"com_incom_all","Net commission income","Итого комиссионный доход",1,yes,yes).*/

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_inexp","Other","Нетто прочие доходы/расходы",1,yes,no).
/*i = i + 1. run kritCreate(i,"com_inexp","Net other incomes/expenses","Нетто прочие доходы/расходы",1,yes,no).*/
i = i + 1. run kritCreate(i,"com_inexp_val","Net incomes/expenses of foreign currency revaluation of assets and liabilities","Нетто доходы/расходы от переоценки валюты",1,yes,no).

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
i = i + 1. run kritCreate(i,"com_audit","Audit and consulting expenses","Расходы по аудиту и консультационным услугам",2,yes,no).
i = i + 1. run kritCreate(i,"com_other","Other operating expenses","Прочие расходы",2,yes,no).
i = i + 1. run kritCreate(i,"com_exp_all","Total operating expenses","Итого операционные расходы",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_precost","Consolidated operating income (pre provision expense)","Консолидированная операционная прибыль(до провизий)",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_prov","Provision expense","Провизии",1,yes,yes).
i = i + 1. run kritCreate(i,"com_prov1","Provisions formed","Ассигнования на резервы",2,no,no).
i = i + 1. run kritCreate(i,"com_prov2","Provisions returned","Доход от восстановления резервов",2,no,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).

i = i + 1. run kritCreate(i,"com_postcost","Consolidated net operating income","Итого консолидированный операционный доход",1,yes,yes).

i = i + 1. run kritCreate(i,"-","","",1,no,no).
/*
i = i + 1. run kritCreate(i,"all_taxes","Taxes","Налоги",1,no,no).

i = i + 1. run kritCreate(i,"-","","",1,no,no).
*/

/*i = i + 1. run kritCreate(i,"com_all_postcost","Net income","Итого чистая прибыль",1,yes,no).*/

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





