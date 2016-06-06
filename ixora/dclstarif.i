/* dclstarif.i
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Запись в таблицу долгов всех комиссий за закрываемый день, потом все будет сниматься
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        24.01.2008 id00004
 * CHANGES
        04/06/2008 madiyar - увеличил экстент в таблице wt до 60
        01/11/2013 Luiza - ТЗ 1932 тариф 948 по экспресс кредитам
        25/11/2013 Luiza ТЗ № 2181 поиск по таблице comon
*/


def temp-table Klir_tab  no-undo
    field  TXB               as char   /* (ALL-для всех филиалов; TXB00 - Алматы; TXB01 - Атырау) */
    field  jur               as char   /* Юридическое/Физическое лицо                             */
    field  payout            as char   /* Внешний платеж                */
    field  vcrc              as char   /* Платеж в ТЕНГЕ               */
    field  scan              as char   /* Сканированный со штрих-кодом */
    field  debet             as char   /* Дебетовая/Кредитовая проводка           */
    field  tarifkod          as char
    field  dt2_more_gtoday   as char   /*  */
    field  dt2_eq_gtoday     as char   /*  */
    field  do_5000000        as char   /*  */
    field  t13_30            as char   /*  */
    field  t14_00            as char   /*  */
    field  rbankTXB          as char   /*  */
    field  urgency           as char
    field  i                 as integer init 0   /*  */
    field  expcred           as logic init no.   /*  */


def temp-table G  no-undo
    field  TXB               as char   /* (ALL-для всех филиалов; TXB00 - Алматы; TXB01 - Атырау) */
    field  jur               as char   /* Юридическое/Физическое лицо                             */
    field  scan              as char   /* Сканированный со штрих-кодом */
    field  tarifkod          as char
    field  dt2_more_gtoday   as char   /*  */
    field dt2_more_dt1       as char
    field  dt2_eq_gtoday     as char   /*  */
    field  do_5000000        as char   /*  */
    field  t13_30            as char   /*  */
    field t14_00             as char
    field  dt2_eq_dt1        as char
    field  urgency           as char
    field  rbankTXB          as char   /*  */
    field  i                 as integer init 0.   /*  */


def temp-table Inet  no-undo
    field  TXB               as char   /* (ALL-для всех филиалов; TXB00 - Алматы; TXB01 - Атырау) */
    field  jur               as char   /* Юридическое/Физическое лицо                             */
    field  tarifkod          as char
    field  dt2_eq_gtoday     as char   /*  */
    field  do_5000000        as char   /*  */
    field t14_00             as char
    field  urgency           as char
    field  rbankTXB          as char   /*  */
    field  i                 as integer init 0.   /*  */





/* Таблица wt промежуточные данные для выгрузки в bxcif */
def temp-table wt no-undo
    field cif    like cif.cif
    field aaa    like aaa.aaa
    field cnt    as   int     extent 60
    field sum    as   decimal extent 60
    field pakal  as   char    extent 60
    field comis  as   char    extent 60
    field crc    as   int     extent 60
    field aaac   like aaa.aaa
    field plat   as char
    index wt /*is unique*/ cif.



/*Тарифы для Клирринга*/


create Klir_tab.  tarifkod = "163". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "no". dt2_eq_gtoday =  "yes". dt2_more_gtoday = "no". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 1. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "215". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "no". dt2_eq_gtoday =  "no". dt2_more_gtoday = "yes". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 2. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "202". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "yes". dt2_eq_gtoday =  "yes". dt2_more_gtoday = "no". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 3. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "222". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "yes". dt2_eq_gtoday =  "no". dt2_more_gtoday = "yes". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 4. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "212". Klir_tab.urgency = "--". TXB = "--". jur = "no". debet = "yes". vcrc = "1".   payout = "yes". scan = "--". dt2_eq_gtoday =  "yes". dt2_more_gtoday = "no". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 5. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "227". Klir_tab.urgency = "--". TXB = "--". jur = "no". debet = "yes". vcrc = "1".   payout = "yes". scan = "--". dt2_eq_gtoday =  "no". dt2_more_gtoday = "yes". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 6. Klir_tab.expcred = no.

create Klir_tab.  tarifkod = "214". Klir_tab.urgency = "yes". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "--". dt2_eq_gtoday =  "--". dt2_more_gtoday = "--". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 7. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "258". Klir_tab.urgency = "yes". TXB = "--". jur = "no".  debet = "yes". vcrc = "1".   payout = "yes". scan = "--". dt2_eq_gtoday =  "--". dt2_more_gtoday = "--". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 8. Klir_tab.expcred = no.
create Klir_tab.  tarifkod = "948". Klir_tab.urgency = "--". TXB = "--".  jur = "--". debet = "--". vcrc = "--".   payout = "--". scan = "--". dt2_eq_gtoday =  "--". dt2_more_gtoday = "--". do_5000000 = "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 9. Klir_tab.expcred = yes.

/*========================*/
/*create Klir_tab.  tarifkod = "022". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "yes". dt2_eq_gtoday =  "no". dt2_more_gtoday = "yes". do_5000000 = "yes". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 1.
create Klir_tab.  tarifkod = "163". Klir_tab.urgency = "no". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan =  "no". dt2_eq_gtoday = "yes". dt2_more_gtoday =  "no". do_5000000 = "yes". t13_30 = "yes". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 4.
create Klir_tab.  tarifkod = "212". Klir_tab.urgency = "no". TXB = "--". jur = "no" . debet = "yes". vcrc = "1".   payout = "yes". scan =  "--". dt2_eq_gtoday = "yes". dt2_more_gtoday =  "no". do_5000000 = "yes". t13_30 = "yes". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 8.
create Klir_tab.  tarifkod = "202". Klir_tab.urgency = "no". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "yes". dt2_eq_gtoday = "yes". dt2_more_gtoday =  "no". do_5000000 = "yes". t13_30 =  "--". t14_00 = "yes". rbankTXB = "--". Klir_tab.i = 9.
*/
/*========================*/
/*create Klir_tab.  tarifkod = "223". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan = "yes". dt2_eq_gtoday =  "no". dt2_more_gtoday = "yes". do_5000000 =  "no". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 10. */
/*create Klir_tab.  tarifkod = "170". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "yes". scan =  "no". dt2_eq_gtoday =  "no". dt2_more_gtoday = "yes". do_5000000 = "yes". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 5. */
/*create Klir_tab.  tarifkod = "165". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "val". payout =  "--". scan =  "--". dt2_eq_gtoday =  "--". dt2_more_gtoday =  "--". do_5000000 =  "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 6. */
/*create Klir_tab.  tarifkod = "166". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "no" . vcrc = "val". payout =  "--". scan =  "--". dt2_eq_gtoday =  "--". dt2_more_gtoday =  "--". do_5000000 =  "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 7. */
/*create Klir_tab.  tarifkod = "141". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "yes". vcrc = "1".   payout = "--".  scan =  "--". dt2_eq_gtoday =  "--". dt2_more_gtoday =  "--". do_5000000 =  "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 2. */
/*create Klir_tab.  tarifkod = "142". Klir_tab.urgency = "--". TXB = "--". jur = "yes". debet = "no".  vcrc = "1".   payout = "--".  scan =  "--". dt2_eq_gtoday =  "--". dt2_more_gtoday =  "--". do_5000000 =  "--". t13_30 =  "--". t14_00 =  "--". rbankTXB = "--". Klir_tab.i = 3. */


/* Тарифы для Гросса */




/*========================*/
/*
create G. G.tarifkod = "214". G.TXB = "--". G.jur = "yes".  G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "yes". G.t13_30 = "yes". G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "yes". G.i = 20.
create G. G.tarifkod = "222". G.TXB = "--". G.jur = "yes".  G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "no".  G.t13_30 = "yes". G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "--".  G.i = 22.
create G. G.tarifkod = "215". G.TXB = "--". G.jur = "yes".  G.scan = "no".  G.dt2_eq_dt1 = "--".  G.dt2_eq_gtoday = "yes". G.dt2_more_dt1 = "yes". G.dt2_more_gtoday = "--". G.do_5000000 = "no".  G.t13_30 = "--".  G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "--".  G.i = 24.
*/
/*========================*/
/*create G. G.tarifkod = "220". G.TXB = "--". G.jur = "yes".  G.scan = "yes". G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "yes". G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "yes". G.t13_30 = "--".  G.t14_00 = "yes". G.rbankTXB = "--". G.urgency = "yes". G.i = 25.*/
/*create G. G.tarifkod = "216". G.TXB = "--". G.jur = "yes".  G.scan = "yes". G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "yes". G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "no".  G.t13_30 = "--".  G.t14_00 = "yes". G.rbankTXB = "--". G.urgency = "--".  G.i = 26.*/
/*create G. G.tarifkod = "259". G.TXB = "--". G.jur = "yes".  G.scan = "yes". G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "yes". G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "--".  G.t13_30 = "--".  G.t14_00 = "no".  G.rbankTXB = "--". G.urgency = "--".  G.i = 27.*/
/*create G. G.tarifkod = "231". G.TXB = "--". G.jur = "no".   G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "yes". G.t13_30 = "yes". G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "yes". G.i = 28.*/
/*create G. G.tarifkod = "227". G.TXB = "--". G.jur = "no".   G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "no".  G.t13_30 = "yes". G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "--".  G.i = 29.*/
/*create G. G.tarifkod = "258". G.TXB = "--". G.jur = "no".   G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "--".  G.t13_30 = "no".  G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "--".  G.i = 30. */
/*create G. G.tarifkod = "257". G.TXB = "--". G.jur = "yes".  G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "--".  G.t13_30 = "no".  G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "--".  G.i = 23.*/
/*create G. G.tarifkod = "229". G.TXB = "--". G.jur = "yes".  G.scan = "no".  G.dt2_eq_dt1 = "yes". G.dt2_eq_gtoday = "--".  G.dt2_more_dt1 = "--".  G.dt2_more_gtoday = "--". G.do_5000000 = "no".  G.t13_30 = "yes". G.t14_00 = "--".  G.rbankTXB = "--". G.urgency = "--".  G.i = 21.*/




/* Тарифы для Интернет-банкинга */

create Inet. Inet.tarifkod = "019". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "--". Inet.t14_00 = "--". Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 9.
create Inet. Inet.tarifkod = "017". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "no".   Inet.do_5000000 = "--". Inet.t14_00 = "--". Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 10.
create Inet. Inet.tarifkod = "233". Inet.TXB = "--". Inet.jur = "no".  Inet.dt2_eq_gtoday = "yes".   Inet.do_5000000 = "--". Inet.t14_00 = "--". Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 11.
create Inet. Inet.tarifkod = "236". Inet.TXB = "--". Inet.jur = "no".  Inet.dt2_eq_gtoday = "no".    Inet.do_5000000 = "--". Inet.t14_00 = "--". Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 12.

create Inet. Inet.tarifkod = "214". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "--".    Inet.do_5000000 = "--". Inet.t14_00 = "--". Inet.rbankTXB = "--". Inet.urgency = "yes".  Inet.i = 13.
create Inet. Inet.tarifkod = "258". Inet.TXB = "--". Inet.jur = "no".  Inet.dt2_eq_gtoday = "--".    Inet.do_5000000 = "--". Inet.t14_00 = "--". Inet.rbankTXB = "--". Inet.urgency = "yes".  Inet.i = 14.


/*========================*/
/*
create Inet. Inet.tarifkod = "019". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "yes". Inet.t14_00 = "yes". Inet.rbankTXB = "--". Inet.urgency = "no".  Inet.i = 40.
create Inet. Inet.tarifkod = "017". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "no".   Inet.do_5000000 = "yes". Inet.t14_00 = "--".  Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 44.
create Inet. Inet.tarifkod = "233". Inet.TXB = "--". Inet.jur = "no".   Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "yes". Inet.t14_00 = "yes". Inet.rbankTXB = "--". Inet.urgency = "no".  Inet.i = 46.
create Inet. Inet.tarifkod = "236". Inet.TXB = "--". Inet.jur = "no".   Inet.dt2_eq_gtoday = "no".   Inet.do_5000000 = "yes". Inet.t14_00 = "--".  Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 50.
*/
/*========================*/
/* create Inet. Inet.tarifkod = "237". Inet.TXB = "--". Inet.jur = "no".   Inet.dt2_eq_gtoday = "no".   Inet.do_5000000 = "no".  Inet.t14_00 = "--".  Inet.rbankTXB = "--". Inet.urgency = "--".  Inet.i = 51. */
/*create Inet. Inet.tarifkod = "221". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "yes". Inet.t14_00 = "yes". Inet.rbankTXB = "--". Inet.urgency = "yes". Inet.i = 41.*/
/*create Inet. Inet.tarifkod = "211". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "no".  Inet.t14_00 = "yes".  Inet.rbankTXB = "--". Inet.urgency = "--". Inet.i = 42.*/
/*create Inet. Inet.tarifkod = "260". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "--".  Inet.t14_00 = "no".   Inet.rbankTXB = "--". Inet.urgency = "--". Inet.i = 43.*/
/* create Inet. Inet.tarifkod = "234". Inet.TXB = "--". Inet.jur = "no".   Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "yes". Inet.t14_00 = "yes". Inet.rbankTXB = "--". Inet.urgency = "yes". Inet.i = 47. */
/* create Inet. Inet.tarifkod = "232". Inet.TXB = "--". Inet.jur = "no".   Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "no".  Inet.t14_00 = "--".   Inet.rbankTXB = "--". Inet.urgency = "--". Inet.i = 48. */
/* create Inet. Inet.tarifkod = "261". Inet.TXB = "--". Inet.jur = "no".   Inet.dt2_eq_gtoday = "yes".  Inet.do_5000000 = "--".  Inet.t14_00 = "no".   Inet.rbankTXB = "--". Inet.urgency = "--". Inet.i = 49. */
/*create Inet. Inet.tarifkod = "246". Inet.TXB = "--". Inet.jur = "yes".  Inet.dt2_eq_gtoday = "no".   Inet.do_5000000 = "no".  Inet.t14_00 = "--".   Inet.rbankTXB = "--". Inet.urgency = "--". Inet.i = 45.*/













/*Процедура perev0 возвращает сумму по коду тарифа*/
Procedure perev0.
    def input parameter s-aaa like aaa.aaa .
    def input parameter komis as char format "x(4)".
    def input parameter tcif like cif.cif .

    def output parameter kod11 like rem.crc1.
    def output parameter tproc   like tarif2.proc .
    def output parameter tmin1   as dec decimals 10 .
    def output parameter tmax1   as dec decimals 10 .
    def output parameter tost    as dec decimals 10 .
    def output parameter pakal as char.
    def output parameter v-err as log.

    def var v-sumkom as dec.
    def var konts like gl.gl.
    def var avl_sum as deci.
    def var comis as logi.

    def buffer bcif for cif.

    v-err = no. tproc = 0. tost = 0.

    find first tarif2 where tarif2.str5 = komis and tarif2.stat = 'r' no-lock no-error.

    if available tarif2 then
    do:
           if tcif <> "" then find first tarifex where tarifex.str5 = tarif2.str5 and tarifex.cif = tcif and tarifex.stat = 'r' no-lock no-error .
           if avail tarifex then
           do:
              if s-aaa ne '' then
                 find first tarifex2 where tarifex2.aaa = s-aaa and tarifex2.cif = tcif and tarifex2.str5 = tarif2.str5 and tarifex2.stat = 'r' no-lock no-error.
                 if avail tarifex2 then do:
                 find first crc where crc.crc = tarifex2.crc no-lock .
                 kod11 = crc.crc.
                 pakal = tarifex2.pakal.
                 konts = tarifex2.kont .

                /* Проверка на неснижаемый остаток */
                 find bcif where bcif.cif = tcif no-lock no-error.
                 comis = yes. /* commission > 0 */
		         avl_sum = avail_bal(s-aaa).
		         if (avail bcif and bcif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
		            if konv2usd(avl_sum,tarifex2.crc,g-today) > tarifex2.nsost then comis = no.
		        end.

            	tproc =  if comis then tarifex2.proc else 0 .
        	tmin1 =  if comis then tarifex2.min1 else 0.
   	        tmax1 =  if comis then tarifex2.max1 else 0.
        	tost  =  if comis then tarifex2.ost  else 0.

            end.
            else do:
            find first crc where crc.crc = tarifex.crc no-lock .
                kod11 = crc.crc.
                pakal = tarifex.pakal.
                konts = tarifex.kont .
                tproc = tarifex.proc .
                tmin1 = tarifex.min1 .
                tmax1 = tarifex.max1 .
                tost  = tarifex.ost .
            end.
           end .
           else
           do :
                find first crc where crc.crc = tarif2.crc no-lock .
                kod11 = crc.crc.
                pakal = tarif2.pakal.
                konts = tarif2.kont .
                tproc = tarif2.proc .
                tmin1 = tarif2.min1 .
                tmax1 = tarif2.max1 .
                tost  = tarif2.ost  .
           end.
  end. /*tarif2*/
     else v-err = yes.
end procedure.
