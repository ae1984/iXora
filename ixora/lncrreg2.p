/* lncrreg2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Экспорт данных в Кредитный Регистр
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        17/02/2005 madiyar
 * CHANGES
        18/02/2005 madiyar - выданная сумма за отчетный период и общая считаются по курсу на день выдачи
                             у некоторых кредитов по физ лицам не введен объект кредитования - обработка ошибки
        22/02/2005 madiyar - исправил ошибку при определении даты списания
        24/02/2005 madiyar - текстовые поля не должны содержать символов ", >, <, <?, ?>
        28/02/2005 madiyar - отрасль физ.лиц - "физ.лица" - 098 (60), вернул назад
        18/03/2005 madiyar - теперь из cif-а подтягивается ОКПО юр.лиц
                             по физ.лицам - имена ИП-шников пишутся не как у других физ.лиц, а полностью в поле lastname
        19/03/2005 madiyar - ОКПО юр.лиц - забыл указать в put'e
                             добавил проверку - на случай если были выдача и полное погашение внутри отчетного месяца
                             в полном имени клиента (руководителя компании) замена последовательности пробелов на один пробел
        20/04/2005 madiyar - статус по классификации определялся текущий, а не за конец отчетного периода - исправил
                             при расчете необх. провизий учитывался 13 уровень (списанный ОД) - исправил
        18/05/2005 madiyar - при наличии 13,14 уровней на начало или конец периода - выводить в кред.регистр
        15/09/2005 madiyar - автоматическое формирование списка групп кредитов юр. лиц
        08/12/2005 madiyar - филиал Актобе - прописал код области
        19/05/2006 madiyar - добавились два поля для юр.лиц - отрасль и форма собственности
        23/05/2006 madiyar - убрал отладочный код
        04/08/2006 madiyar - филиал Караганда - прописал код области
        04/10/2006 madiyar - филиал Талдыкорган - прописал код области
        09/11/2006 madiyar - кредиты КИК - отдельная обработка
        02/07/2007 madiyar - проставление кода области/города, txb01 - Актобе
        18/02/2008 madiyar - кода областей/городов
        14/04/2008 madiyar - новые филиалы, кода областей/городов
        13/05/2008 madiyar - новые филиалы, кода областей/городов
        20/10/2008 madiyar - евро 11->3
        13/11/2008 madiyar - перекодировка файла не нужна, убрал
        15/12/2008 galina - берем провизии не только в тенге, но и в валюте с пересчетом по курсу в тенге
        11/03/2009 madiyar - общая выданная сумма займа = (выд. за отчетный период + до отчетного периода)
        19/04/2010 madiyar - признак связи с банком особыми отношениями определяем из справочника prisv
        10/06/2010 madiyar - поправил выгрузку в связи с изменениями в справочнике объектов кредитования
        10/08/2010 madiyar - по ИП - вылетала ошибка при распарсивании наименования, исправил
        13/08/2010 madiyar - ИП - берем ФИО первого руководителя
        16/08/2010 k.gitalov - вместо формирования файлов - заполнение темп таблицы cr_wrk
        19/11/2010 madiyar - изменения по залогам и в определении принадлежности к МСБ (v-small_en)
        14/12/2010 madiyar - подправил определение счета ГК
        17/01/2011 madiyar - изменения в связи с начислением провизий на %% и штрафы; признак КЛ по траншам
        26/01/2011 madiyar - подправил проставление признака КЛ по траншам
        17/03/2011 madiyar - обновил соответствие отраслей
        25/04/2011 id00810 - для аккредитивов и гарантий из модуля ТФ
        11/05/2011 madiyar - подправил определение типа обеспечения
        17/06/2011 madiyar - дополнил справочник организационно-правовых форм
        23/06/2011 id00810 - для аккредитивов: учет реквизита DtNar при определении даты фактического погашения
        15/07/2011 id00810 - дополнила справочник ОПФ (полное товарищество), подправила заполнение полей comment1,comment2
        15/08/2011 madiyar - провизии по АФН теперь на уровне 41
        13/09/2011 id00810 - для аккредитивов: убрала проверку даты истечения DtExp,
        06/01/2011 kapar - Наименование ИП перенес на v-comment[2]
        19/03/2011 kapar - ТЗ 1320
        06/04/2012 id00810 - для гарантий и аккредитивов добавила первоначальное присвоение v-specrel = "100"
        06/06/2012 kapar - исправил мелкие ошибки кода
        03/07/2012 kapar - первоначальное присвоение v-specrel = "171" и исправление справочника связ с БВУ
        19/07/2012 id00810 - добавление кода новой валюты
        18/09/2012 id00810 - переход на bookcod при определении кода валюты
        13/03/2013 sayat(id01143) - ТЗ 1758 поиск связи особыми отношениями по ИИН/БИН, в поле rnn передаем ИИН/БИН (и РНН если ИИН/БИН отсутствует)
        04/07/2013 sayat(id01143) - ТЗ 1950 от 04/07/2013 "Касательно доработок в АИП "Кредитный регистр"" изменено определение ЮЛ/ФЛ (кроме займов lon):
                                    клиенты с типом "b", но группами 403-ИП,405-КХ и 605-нотариальные платы(частный нотариус) передаются как ФЛ.
        02/09/2013 galina - ТЗ1918 перекомпиляция

*/


def input parameter dat as date no-undo.
def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.

def shared var g-today as date.
def shared var v-bik as char.
def shared var rates as deci extent 20.
def shared var mesa as char.
def shared var v-spcrc1 as char no-undo.
def shared var v-spcrc2 as char no-undo.
{credreg.i}


def shared temp-table lnpr no-undo
  field cif    as   char
  field lon    as   char
  field n1     as   decimal
  field n2     as   decimal
  field n3     as   decimal
  field n4     as   decimal
  field n5     as   decimal.


function ns_check returns character (input parm as character).
  def var v-str as char no-undo.
  v-str = parm.
  if index(v-str,"""") > 0 then v-str = replace(v-str,"""","").
  if index(v-str,'"') > 0 then v-str = replace(v-str,'"',"").
  if index(v-str,"'") > 0 then v-str = replace(v-str,"'","").
  if index(v-str,"<?") > 0 then v-str = replace(v-str,"<?","").
  if index(v-str,"?>") > 0 then v-str = replace(v-str,"?>","").
  if index(v-str,"<") > 0 then v-str = replace(v-str,"<","").
  if index(v-str,">") > 0 then v-str = replace(v-str,">","").
  if index(v-str,"&") > 0 then v-str = replace(v-str,"&","").
  return (v-str).
end function.

{trim.i}

def var p-cif1 like txb.cif.cif.
def var p-cif2 like txb.cif.cif.
def var v-file as char no-undo init "loans".

def var v-sep as char no-undo init "^".

def var s-bank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause.
  return.
end.
else s-bank = txb.sysc.chval.

def var v-bikf as char no-undo.
find first txb where txb.bank = s-bank and txb.consolid no-lock no-error.
if avail txb then v-bikf = txb.mfo.

def var v-reptype as int no-undo.
def var v-urfiz as int no-undo.

def var v-small_en as int no-undo.
def var v-currency as int no-undo.
def var v-inirate as deci no-undo.
def var v-dt_givefact as date no-undo.
def var v-sum_givefact as deci no-undo.
def var v-total_sum_givefact as deci no-undo.
def var v-dt_prolong as date no-undo.
def var v-lntgt as integer no-undo.
def var v-stsclass as integer no-undo.

def var lonsecsum as deci no-undo extent 10.
def var v-typeobes as integer no-undo.
def var v-costobes as decimal no-undo.
def var v-costobes2 as decimal no-undo.
def var v-maxcost as decimal no-undo.

def var v-gl as integer no-undo extent 3.
def var v-glnum as integer no-undo extent 3.
def var bilance_per as decimal no-undo extent 2.
def var bilance_spis as decimal no-undo extent 2.
def var bilance_kik as decimal no-undo.
def var bilance as decimal no-undo extent 3.
def var v-proc as decimal no-undo extent 3.
def var v-dt_naprosr as date no-undo.
def var v-dt_naspis as date no-undo.
def var v-summ as decimal no-undo.
def var v-dt_expfact as date no-undo.
def var v-provreq as deci no-undo.
def var v-provfact as deci no-undo.
def var v-prov6 as deci no-undo.
def var v-prov36 as deci no-undo.
def var v-prov37 as deci no-undo.
def var v-prov41 as deci no-undo.
def var v-provc as deci no-undo.
/*
def var v-provlog as logi no-undo.
*/

def var v-bossname as char no-undo.
def var id_obl as integer no-undo.
def var v-okpo as char no-undo.
def var v-lastname as char no-undo.
def var v-firstname as char no-undo.
def var v-middlename as char no-undo.

def var id_otrasl as char no-undo.
def var otrasl_tex as char no-undo init "0,01,02,03,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,35,36,37,38,39,41,42,43,45,46,47,49,50,51,52,53,55,56,58,59,60,61,62,63,64,65,66,68,69,70,71,72,73,74,75,77,78,79,80,81,82,84,85,86,87,88,90,91,92,93,94,95,96,97,98,99".
def var otrasl_afn as char no-undo init "60,1,97,98,65,95,7,8,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,110,111,112,99,100,101,107,108,109,102,103,104,105,113,114,115,116,117,118,106,119,120,121,122,123,149,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,150,151,152,148".

def var id_form as char no-undo.
def var form_tex as char no-undo init "ГП,РГП,ПТ,КТ,ТОО,ТДО,АО,АОЗТ,ЗАО,АООТ,ОАО,ПК,Учреждение,ОО,ООО,РОО,ПоК,ИП,ПОЛНОЕ ТОВАРИЩЕСТВО".
def var form_afn as char no-undo init " 1,  1, 5, 6,  7,  8, 9,  10, 10,  11, 11,12,        13,14, 14, 14, 15,123,5".

def var v-specrel as char no-undo.
/*def var specrel_tex as char no-undo init "12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34".*/
/*def var specrel_afn as char no-undo init "78,79,80,81,82,83,84,85,98,87,88,89,90,91,92,93,94,95,96,97,100,102,103".*/
def var specrel_tex as char no-undo init "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50".
def var specrel_afn as char no-undo init "122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171".

/* перечень кодов признака lnshifr для выделения субъектов малого предпринимательства */
def var codelist as char no-undo init "03,04,07,08,11,12,15,16,19,20,23,24".

def var i as integer no-undo.
def var v-sc as char no-undo.
def var numcred as integer no-undo.
def var numfiz as integer no-undo.
def var numur as integer no-undo.

def var garcount as int no-undo.
def var tmp_s as char no-undo.

def var v-usual_credit as logical no-undo init no.
def var v-uo_kik as logical no-undo init no.

def var v-comment as char no-undo extent 2.

def var v-cover   as char no-undo.
def var v-dt1     as date no-undo.
def var v-dt2     as date no-undo.
def var v-dt3     as date no-undo.
def var v-sum1    as deci no-undo.
def var v-sum2    as deci no-undo.
def var v-gar     as logi no-undo.
def var v-cod     as char no-undo.
def var v-name    as char no-undo.
def var akkrcount as int  no-undo.
def var v-crc     as int  no-undo.
def var v-per     as int  no-undo.

/* группы кредитов юридических лиц */
def var lst_ur as char no-undo init ''.
for each txb.longrp no-lock:
  if substr(string(txb.longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(txb.longrp.longrp).
  end.
end.

case s-bank:
when "txb00" then id_obl = 2. /* г. Алматы */
when "txb01" then id_obl = 4. /* Актобе, Актюбинская обл */
when "txb02" then id_obl = 10. /* Костанай, Костанайская обл */
when "txb03" then id_obl = 8. /* Тараз, Жамбылская обл */
when "txb04" then id_obl = 7. /* Уральск, ЗКО */
when "txb05" then id_obl = 9. /* Караганда, Карагандинская обл */
when "txb06" then id_obl = 15. /* Семей, ВКО */
when "txb07" then id_obl = 3. /* Кокшетау, Акмолинская обл */
when "txb08" then id_obl = 1. /* г. Астана */
when "txb09" then id_obl = 13. /* Павлодар, Павлодарская обл */
when "txb10" then id_obl = 16. /* Петропавловск, СКО */
when "txb11" then id_obl = 6. /* Атырау, Атырауская обл */
when "txb12" then id_obl = 12. /* Актау, Мангистауская обл */
when "txb13" then id_obl = 9. /* Жезказган, Карагандинская обл */
when "txb14" then id_obl = 15. /* Усть-Каменогорск, ВКО */
when "txb15" then id_obl = 14. /* Шымкент, ЮКО */
when "txb16" then id_obl = 2. /* г. Алматы */

/*
when "txb01" then id_obl = 1. -- г. Астана --
when "txb02" then id_obl = 7. -- Западно-Казахстанская обл --
when "txb03" then id_obl = 6. -- Атырауская обл --
when "txb04" then id_obl = 4. -- Актюбинская обл --
when "txb05" then id_obl = 9. -- Карагандинская обл --
when "txb06" then id_obl = 5. -- Алматинская обл --
*/

end case.

hide message no-pause.
message " Обработка " + s-bank + " ".

/*
def stream rep.
output stream rep to value(v-file + "_" + s-bank + ".rgl").
*/

garcount = 0. numcred = 0. numur = 0. numfiz = 0. p-cif1 = ''. p-cif2 = ''.

/*where txb.lon.cif = "K11015"*/
for each txb.lon no-lock break by txb.lon.cif:

  if first-of(txb.lon.cif) then p-cif1 = txb.lon.cif.

  if txb.lon.opnamt = 0 then next.
  if txb.lon.rdt >= dat then next.

  v-comment = ''.

  if lookup(string(txb.lon.grp),lst_ur) > 0 then v-urfiz = 0. /* ur */
  else v-urfiz = 1. /* fiz */

  v-reptype = v-urfiz + 1.

  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"1,7,13,14",no,txb.lon.crc,output bilance_per[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1,7,13,14",yes,txb.lon.crc,output bilance_per[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"13,14",no,txb.lon.crc,output bilance_spis[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13,14",yes,txb.lon.crc,output bilance_spis[2]).

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"6",yes,txb.lon.crc,output v-prov6).
  v-prov6 = - v-prov6.
  if txb.lon.crc <> 1 then v-prov6 = v-prov6 * rates[txb.lon.crc].

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"36",yes,txb.lon.crc,output v-prov36).
  v-prov36 = - v-prov36.
  if txb.lon.crc <> 1 then v-prov36 = v-prov36 * rates[txb.lon.crc].

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"37",yes,1,output v-prov37).
  v-prov37 = - v-prov37.

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"41",yes,txb.lon.crc,output v-prov41).
  v-prov41 = - v-prov41.
  if txb.lon.crc <> 1 then v-prov41 = v-prov41 * rates[txb.lon.crc].

  v-provc = v-prov6 + v-prov36 + v-prov37.

  /* проверка на случай если были выдача и погашение внутри отчетного месяца */
  find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and (txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2) and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock no-error.

  v-usual_credit = (bilance_per[1] + bilance_per[2] + bilance_spis[1] + bilance_spis[2] + v-provc + v-prov41 > 0) or (avail txb.lnscg).

  /* проверка, продан ли кредит в КИК */
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"26",yes,txb.lon.crc,output bilance_kik).
  v-uo_kik = (bilance_kik > 0).

  if not(v-usual_credit or v-uo_kik) then next.

  v-dt_expfact = ?.
  if bilance_per[2] <= 0 then do:
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= dt2 and (txb.lonres.lev = 1 or txb.lonres.lev = 7) and txb.lonres.dc = "C" no-lock no-error.
    if avail txb.lonres then v-dt_expfact = txb.lonres.jdt.
  end.

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1",yes,txb.lon.crc,output bilance[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"7",yes,txb.lon.crc,output bilance[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13",yes,txb.lon.crc,output bilance[3]).

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"2",yes,txb.lon.crc,output v-proc[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"9",yes,txb.lon.crc,output v-proc[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"14",yes,txb.lon.crc,output v-proc[3]).


  find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
  find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

  v-okpo = ''. id_otrasl = ''. id_form = ''.
  if v-urfiz = 0 then do:

    v-okpo = trim(txb.cif.ssn).

    i = lookup(trim(txb.cif.prefix),form_tex).
    if i > 0 then id_form = trim(entry(i,form_afn)).
    if id_form = '' then do:
      message txb.lon.cif + ' ' + txb.lon.lon + ": """ + txb.cif.prefix + """ is not defined" view-as alert-box buttons ok.
      id_form = "144".
    end.

    find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" no-lock no-error.
    if avail txb.sub-cod then do:
      i = lookup(txb.sub-cod.ccode,otrasl_tex).
      if i > 0 then id_otrasl = trim(entry(i,otrasl_afn)).
    end.
    if id_otrasl = '' then do:
      message txb.lon.cif + ' ' + txb.lon.lon + ": ecdivis is not defined" view-as alert-box buttons ok.
      id_otrasl = "-1".
    end.
  end.

  v-small_en = 0.
  /*
  find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lneko" no-lock no-error.
  if avail txb.sub-cod then do:
    if txb.sub-cod.ccode = '72' or txb.sub-cod.ccode = '72.1' then v-small_en = 1.
  end.
  */
  find txb.sub-cod where txb.sub-cod.sub = 'LON' and txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.d-cod = 'lnshifr' no-lock no-error.
  if avail txb.sub-cod then do:
    if lookup(txb.sub-cod.ccode,codelist) > 0 then v-small_en = 1.
  end.


  v-specrel = "171".
  /*
  find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lnsrel" no-lock no-error.
  if avail txb.sub-cod then do:
    if txb.sub-cod.ccode = '1' then v-specrel = 78.
  end.
  */
  if txb.cif.bin <> '' then find first prisv where prisv.rnn = txb.cif.bin no-lock no-error.
  else find first prisv where caps(prisv.name) = caps(txb.cif.name)  no-lock no-error.
  if avail prisv then do:
      i = lookup(trim(prisv.specrel),specrel_tex).
      if i > 0 then v-specrel = trim(entry(i,specrel_afn)).
  end.

  /*case txb.lon.crc:
    when 1 then v-currency = 4.
    when 2 then v-currency = 3.
    when 3 then v-currency = 112.
  end case.*/
  i = lookup(string(txb.lon.crc),v-spcrc1).
  if i > 0 then v-currency = int(entry(i,v-spcrc2)).
  else do:
    v-currency = ?.
    message txb.lon.cif + ' ' + txb.lon.lon + ": не определяется код валюты для Кредитного регистра" view-as alert-box buttons ok.
  end.

  find first txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat = txb.lon.rdt no-lock no-error.
  if avail txb.ln%his then v-inirate = txb.ln%his.intrate.
  else v-inirate = txb.lon.prem.
  if v-inirate > 100 then v-inirate = txb.lon.prem.

  v-dt_givefact = txb.lon.rdt.
  find first txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock no-error.
  if avail txb.lnscg then v-dt_givefact = txb.lnscg.stdat.

  /* фактически выданные суммы - за отчетный период и общая (считаем сразу в тенге) */
  v-sum_givefact = 0. v-total_sum_givefact = 0.
  for each txb.lnscg where txb.lnscg.lng = txb.lon.lon and txb.lnscg.f0 > - 1 and txb.lnscg.fpn = 0 and txb.lnscg.flp > 0 no-lock:
    if txb.lnscg.stdat > dt2 then next. /* берем только выдачи до конца отчетного периода, более поздние - не учитываем */
    if txb.lon.crc = 1 then do:
      v-total_sum_givefact = v-total_sum_givefact + txb.lnscg.paid.
      if txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2 then v-sum_givefact = v-sum_givefact + txb.lnscg.paid.
    end.
    else do:
      find last txb.crchis where txb.crchis.crc = txb.lon.crc and txb.crchis.rdt <= txb.lnscg.stdat no-lock no-error.
      if not avail txb.crchis then do:
        displ txb.lon.lon txb.lon.crc txb.lnscg.stdat.
        find first txb.crchis where txb.crchis.crc = txb.lon.crc no-lock no-error.
      end.
      v-total_sum_givefact = v-total_sum_givefact + txb.lnscg.paid * txb.crchis.rate[1].
      if txb.lnscg.stdat >= dt1 and txb.lnscg.stdat <= dt2 then v-sum_givefact = v-sum_givefact + txb.lnscg.paid * txb.crchis.rate[1].
    end.
  end.

  v-dt_prolong = ?.
  if txb.lon.ddt[5] <> ? then v-dt_prolong = txb.lon.ddt[5].
  if txb.lon.cdt[5] <> ? then v-dt_prolong = txb.lon.cdt[5].

  v-lntgt = 0.
  find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lntgt" no-lock no-error.
  if avail txb.sub-cod then do:
    if txb.sub-cod.ccode <> "msc" then do:

      case txb.sub-cod.ccode:
        when "17" then v-lntgt = 117.
        when "18" then v-lntgt = 8.
        when "19" then v-lntgt = 8.
        when "20" then v-lntgt = 8.
        otherwise do:
            v-lntgt = integer(txb.sub-cod.ccode) no-error.
            v-lntgt = v-lntgt - 9.
            if v-lntgt < 0 then v-lntgt = 0.
        end.
      end case.

    end.
  end.
  if v-lntgt = 0 then do:
    message s-bank + " " + txb.lon.lon + ": object is not defined" view-as alert-box buttons ok.
    v-lntgt = 6.
  end.

  v-stsclass = 0. v-provreq = 0. v-provfact = 0.
  find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= dt2 no-lock no-error.
  if not avail txb.lonhar then find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
  if avail txb.lonhar then do:
    case txb.lonhar.lonstat:
      when 1 then v-stsclass = 1.
      otherwise v-stsclass = txb.lonhar.lonstat + 1.
    end case.
    /*
    find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    v-provreq = (bilance[1] + bilance[2]) * rates[lon.crc] * txb.lonstat.prc / 100.
    */

  end.
  else message txb.lon.cif + ' ' + txb.lon.lon + ": не определен статус по классификации" view-as alert-box buttons ok.

 /* else message txb.lon.lon + ": classification status is not defined" view-as alert-box buttons ok.*/
/*
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"41",yes,txb.lon.crc,output v-provfact).
  v-provfact = - v-provfact.
  if txb.lon.crc <> 1 then v-provfact = v-provfact * rates[txb.lon.crc].

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"6,36,37",yes,txb.lon.crc,output v-provreq).
  v-provreq = - v-provreq.
  if txb.lon.crc <> 1 then v-provreq = v-provreq * rates[txb.lon.crc].
*/

  v-provfact = v-prov41.
  v-provreq = v-provc.

  /*
  v-provlog = no.
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"42",yes,txb.lon.crc,output v-provc).
  v-provc = - v-provc.
  if txb.lon.crc <> 1 then v-provc = v-provc * rates[txb.lon.crc].
  if v-provc > 0 then do:
    v-provlog = yes.
    v-provfact = v-provfact + v-provc.
  end.

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"43",yes,1,output v-provc).
  v-provc = - v-provc.
  if v-provc > 0 then do:
    v-provlog = yes.
    v-provfact = v-provfact + v-provc.
  end.

  if v-provlog then v-comment[2] = "Провизии сформированы в т.ч. на вознаграждение/штрафы".
  */

  lonsecsum = 0.

  for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
    if (txb.lonsec1.lonsec < 1) or (txb.lonsec1.lonsec > 10) then next.
    lonsecsum[txb.lonsec1.lonsec] = lonsecsum[txb.lonsec1.lonsec] + txb.lonsec1.secamt * rates[lonsec1.crc].
  end.

  v-costobes = 0. v-maxcost = 0. v-typeobes = 0.
  v-costobes2 = 0.
  do i = 1 to 10:
    if (i <> 5) then do:
        v-costobes = v-costobes + lonsecsum[i].
        if (i <> 6) then do:
            v-costobes2 = v-costobes2 + lonsecsum[i].
            if lonsecsum[i] > v-maxcost then do:
                v-typeobes = i.
                v-maxcost = lonsecsum[i].
            end.
        end.
    end.
  end.

  if v-costobes2 = 0 and lonsecsum[6] > 0 then v-typeobes = 6.

  if v-typeobes = 6 then v-typeobes = 7. /* не совпадают гарантии и поручительства */
  if v-typeobes = 0 then do:
      find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec <> 5 no-lock no-error.
      if avail txb.lonsec1 then v-typeobes = txb.lonsec1.lonsec.
      else v-typeobes = 5. /* беззалоговые (бланковые) кредиты */
  end.

  if (v-typeobes <> 5) and (v-costobes = 0) then do:
    find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec = v-typeobes no-lock no-error.
    if avail txb.lonsec1 then v-comment[1] = ns_check(trim(txb.lonsec1.prm)).
  end.

  /*
  счета ГК :  1411 1 7 1
              ---- - - -
               |   | | валюта (1 - тенге, 2 - СКВ, 3 - ДВВ)
               |   | юр/физ (7 - юр, 9 - физ)
               |   резидентство (1 - резидент, 2 - нерезидент)
               4 цифры балансового счета
  */

  /*
  message substring(string(lon.gl),1,4) view-as alert-box buttons ok.
  message if cif.geo = "021" then "1" else "2" view-as alert-box buttons ok.
  message if v-urfiz = 0 then "7" else "9" view-as alert-box buttons ok.
  message if lon.crc = 1 then "1" else "2" view-as alert-box buttons ok.
  message substring(string(lon.gl),1,4) + if cif.geo = "021" then "1" else "2" + if v-urfiz = 0 then "7" else "9" + if lon.crc = 1 then "1" else "2" view-as alert-box buttons ok.
  */

  /*
  --ОД--      v-gl[1] = integer(substring(string(txb.lon.gl),1,4) + if txb.cif.geo = "021" then "1" else "2" + if v-urfiz = 0 then "7" else "9" + if txb.lon.crc = 1 then "1" else "2").
  --просрОД-- v-gl[2] = integer("1424" + if cif.geo = "021" then "1" else "2" + if v-urfiz = 0 then "7" else "9" + if txb.lon.crc = 1 then "1" else "2").
  --списОД--  v-gl[3] = 7130000.
  */

  v-gl = 0. v-glnum = 0.
  v-sc = ''.
  if txb.cif.geo = "021" then v-sc = v-sc + "1". else v-sc = v-sc + "2".
  if v-urfiz = 0 then do:
    find first txb.sub-cod where txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.sub = "CLN" and txb.sub-cod.d-cod = "secek" no-lock no-error.
    if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-sc = v-sc + txb.sub-cod.ccode.
    else v-sc = v-sc + "7".
  end.
  else v-sc = v-sc + "9".
  if txb.lon.crc = 1 then v-sc = v-sc + "1". else v-sc = v-sc + "2".

  v-gl[1] = integer(substring(string(lon.gl),1,4) + v-sc).
  v-gl[2] = integer("1424" + v-sc).

  /*
  message string(v-gl[1]) + " " + string(v-gl[2]) view-as alert-box buttons ok.
  message string(v-glnum[1]) + " " + string(v-glnum[2]) view-as alert-box buttons ok.
  */

  v-glnum[3] = 831.



  do i = 1 to 2:
    case v-gl[i]:
      when 1407111 then v-glnum[i] = 371.
      when 1407112 then v-glnum[i] = 372.
      when 1407121 then v-glnum[i] = 373.
      when 1407122 then v-glnum[i] = 374.
      when 1407141 then v-glnum[i] = 945.
      when 1407142 then v-glnum[i] = 377.
      when 1407151 then v-glnum[i] = 379.
      when 1407152 then v-glnum[i] = 380.
      when 1407161 then v-glnum[i] = 382.
      when 1407162 then v-glnum[i] = 383.
      when 1407171 then v-glnum[i] = 385.
      when 1407172 then v-glnum[i] = 386.
      when 1407181 then v-glnum[i] = 388.
      when 1407182 then v-glnum[i] = 389.
      when 1407191 then v-glnum[i] = 391.
      when 1407192 then v-glnum[i] = 392.

      when 1411111 then v-glnum[i] = 466.
      when 1411112 then v-glnum[i] = 467.
      when 1411121 then v-glnum[i] = 469.
      when 1411122 then v-glnum[i] = 470.
      when 1411151 then v-glnum[i] = 1053.
      when 1411152 then v-glnum[i] = 1054.
      when 1411161 then v-glnum[i] = 472.
      when 1411162 then v-glnum[i] = 473.
      when 1411171 then v-glnum[i] = 947.
      when 1411172 then v-glnum[i] = 475.
      when 1411181 then v-glnum[i] = 477.
      when 1411182 then v-glnum[i] = 478.
      when 1411191 then v-glnum[i] = 480.
      when 1411192 then v-glnum[i] = 948.
      when 1411261 then v-glnum[i] = 488.
      when 1411262 then v-glnum[i] = 489.
      when 1411271 then v-glnum[i] = 491.
      when 1411272 then v-glnum[i] = 492.
      when 1411281 then v-glnum[i] = 494.
      when 1411282 then v-glnum[i] = 949.
      when 1411291 then v-glnum[i] = 496.
      when 1411292 then v-glnum[i] = 497.

      when 1417111 then v-glnum[i] = 499.
      when 1417112 then v-glnum[i] = 500.
      when 1417121 then v-glnum[i] = 502.
      when 1417122 then v-glnum[i] = 503.
      when 1417151 then v-glnum[i] = 1056.
      when 1417152 then v-glnum[i] = 1057.
      when 1417161 then v-glnum[i] = 950.
      when 1417162 then v-glnum[i] = 505.
      when 1417171 then v-glnum[i] = 507.
      when 1417172 then v-glnum[i] = 508.
      when 1417181 then v-glnum[i] = 510.
      when 1417182 then v-glnum[i] = 511.
      when 1417191 then v-glnum[i] = 513.
      when 1417192 then v-glnum[i] = 514.
      when 1417261 then v-glnum[i] = 522.
      when 1417262 then v-glnum[i] = 523.
      when 1417271 then v-glnum[i] = 525.
      when 1417272 then v-glnum[i] = 526.
      when 1417281 then v-glnum[i] = 528.
      when 1417282 then v-glnum[i] = 529.
      when 1417291 then v-glnum[i] = 531.
      when 1417292 then v-glnum[i] = 532.

      when 1424111 then v-glnum[i] = 688.
      when 1424112 then v-glnum[i] = 689.
      when 1424121 then v-glnum[i] = 691.
      when 1424122 then v-glnum[i] = 692.
      when 1424151 then v-glnum[i] = 1068.
      when 1424152 then v-glnum[i] = 1069.
      when 1424161 then v-glnum[i] = 694.
      when 1424162 then v-glnum[i] = 695.
      when 1424171 then v-glnum[i] = 697.
      when 1424172 then v-glnum[i] = 698.
      when 1424181 then v-glnum[i] = 952.
      when 1424182 then v-glnum[i] = 699.
      when 1424191 then v-glnum[i] = 701.
      when 1424192 then v-glnum[i] = 702.
      when 1424211 then v-glnum[i] = 704.
      when 1424212 then v-glnum[i] = 705.
      when 1424221 then v-glnum[i] = 707.
      when 1424222 then v-glnum[i] = 708.
      when 1424261 then v-glnum[i] = 710.
      when 1424262 then v-glnum[i] = 711.
      when 1424271 then v-glnum[i] = 713.
      when 1424272 then v-glnum[i] = 953.
      when 1424281 then v-glnum[i] = 715.
      when 1424282 then v-glnum[i] = 716.
      when 1424291 then v-glnum[i] = 718.
      when 1424292 then v-glnum[i] = 719.
      when 7130000 then v-glnum[i] = 831.

      when 1401111 then v-glnum[i] = 246.
      when 1401112 then v-glnum[i] = 247.
      when 1401121 then v-glnum[i] = 249.
      when 1401122 then v-glnum[i] = 250.
      when 1401151 then v-glnum[i] = 1059.
      when 1401152 then v-glnum[i] = 1060.
      when 1401161 then v-glnum[i] = 252.
      when 1401162 then v-glnum[i] = 254.
      when 1401171 then v-glnum[i] = 257.
      when 1401172 then v-glnum[i] = 256.
      when 1401181 then v-glnum[i] = 259.
      when 1401182 then v-glnum[i] = 260.
      when 1401191 then v-glnum[i] = 262.
      when 1401192 then v-glnum[i] = 263.
      when 1401211 then v-glnum[i] = 265.
      when 1401212 then v-glnum[i] = 266.
      when 1401221 then v-glnum[i] = 268.
      when 1401222 then v-glnum[i] = 269.
      when 1401261 then v-glnum[i] = 271.
      when 1401262 then v-glnum[i] = 272.
      when 1401271 then v-glnum[i] = 274.
      when 1401272 then v-glnum[i] = 275.
      when 1401281 then v-glnum[i] = 277.
      when 1401282 then v-glnum[i] = 278.
      when 1401291 then v-glnum[i] = 280.
      when 1401292 then v-glnum[i] = 281.

    end case.
  end.

  /*
  message string(v-glnum[1]) + " " + string(v-glnum[2]) view-as alert-box buttons ok.
  */

  v-dt_naprosr = ?.
  if bilance[2] > 0 then do:
    v-summ = 0.
    for each txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= dt2 and txb.lonres.lev = 7 no-lock break by txb.lonres.jdt desc:
      if txb.lonres.dc <> "D" then next.
      v-dt_naprosr = txb.lonres.jdt. v-summ = v-summ + txb.lonres.amt.
      if v-summ >= bilance[2] then leave.
    end.
  end.

  v-dt_naspis = ?.
  if bilance[3] > 0 then do:
    find first txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= dt2 and txb.lonres.lev = 13 and txb.lonres.dc = "D" no-lock no-error.
    if avail txb.lonres then v-dt_naspis = txb.lonres.jdt.
  end.

  v-bossname = ''.
  if v-urfiz = 0 then do:
    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
    if avail txb.sub-cod then v-bossname = GTrim(txb.sub-cod.rcode).
  end.


   if v-urfiz = 1 then do:
    tmp_s = GTrim(txb.cif.name).
    if txb.cif.type = 'b' then do:
        v-comment[2] = ns_check(GTrim((txb.cif.prefix) + " " + trim(txb.cif.name))).
        find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
        if avail txb.sub-cod and (trim(txb.sub-cod.rcode) <> '') then do:
            v-bossname = GTrim(txb.sub-cod.rcode).
            v-lastname = ns_check(entry(1,v-bossname,' ')).
            if num-entries(v-bossname,' ') > 1 then v-firstname = ns_check(entry(2,v-bossname,' ')).
            else v-firstname = ''.
            if num-entries(v-bossname,' ') > 2 then v-middlename = ns_check(entry(3,v-bossname,' ')).
            else v-middlename = ''.
        end.
        else do:
         message txb.lon.cif + ' ' + txb.lon.lon + ": (ИП) не указаны ФИО первого руководителя" view-as alert-box buttons ok.
         v-bossname = ''.
         v-lastname = ''.
         v-firstname = ''.
         v-middlename = ''.
        end.
    end.
    else do:
        v-lastname = ns_check(entry(1,tmp_s,' ')).
        if num-entries(tmp_s,' ') > 1 then v-firstname = ns_check(entry(2,tmp_s,' ')).
        else v-firstname = ''.
        if num-entries(tmp_s,' ') > 2 then v-middlename = ns_check(entry(3,tmp_s,' ')).
        else v-middlename = ''.
    end.
   end.

/*
if v-urfiz = 1 then do:
    tmp_s = GTrim(txb.cif.name).
    if v-small_en = 0 then do:
      v-lastname = ns_check(entry(1,tmp_s,' ')).
      if num-entries(tmp_s,' ') > 1 then v-firstname = ns_check(entry(2,tmp_s,' ')).
      else v-firstname = "".
      if num-entries(tmp_s,' ') > 2 then v-middlename = ns_check(entry(3,tmp_s,' ')).
      else v-middlename = "".
    end.
    else do:
      v-lastname = trim(txb.cif.prefix) + " " + trim(tmp_s).
      v-firstname = "О".
      v-middlename = ''.
    end.
  end.
*/

  create cr_wrk.

  if v-usual_credit then do:

      cr_wrk.is_natural_person = v-urfiz.
      cr_wrk.bik_main_office = v-bik.
      cr_wrk.bik_filial = v-bikf.
      cr_wrk.data_rep = dat.
      cr_wrk.contract_number = ns_check(txb.loncon.lcnt).
      cr_wrk.contract_date = txb.lon.rdt.

      if v-urfiz = 1 then do:
            if txb.cif.bin <> '' then cr_wrk.rnn = txb.cif.bin.
            else cr_wrk.rnn = txb.cif.jss.
            cr_wrk.last_name = v-lastname.
            cr_wrk.first_name = v-firstname.
            cr_wrk.middle_name = v-middlename.
            if trim(txb.cif.addr[1]) <> '' then cr_wrk.address = ns_check(trim(txb.cif.addr[1])).
            else cr_wrk.address = ns_check(trim(txb.cif.addr[2])).
            cr_wrk.id_region = id_obl.
            if txb.cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
            if txb.cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.
            cr_wrk.is_small_enterprise = v-small_en.
            cr_wrk.id_otrasl = 60.
            cr_wrk.id_special_rel_with_bank = integer(v-specrel).
      end.
      else do:
            if txb.cif.bin <> '' then cr_wrk.rnn = txb.cif.bin.
            else cr_wrk.rnn = txb.cif.jss.
            cr_wrk.okpo = v-okpo.
            cr_wrk.name = ns_check(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
            if txb.cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
            if txb.cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.
            if num-entries(v-bossname,' ') > 0 then cr_wrk.last_name = ns_check(entry(1,v-bossname,' ')).
            if num-entries(v-bossname,' ') > 1 then cr_wrk.first_name = ns_check(entry(2,v-bossname,' ')).
            if num-entries(v-bossname,' ') > 2 then cr_wrk.middle_name = ns_check(entry(3,v-bossname,' ')).
            cr_wrk.is_small_enterprise = v-small_en.
            if id_otrasl <> '' then cr_wrk.id_otrasl = integer(id_otrasl).
            if id_form <> '' then cr_wrk.id_form_law = integer(id_form).
            cr_wrk.id_special_rel_with_bank = integer(v-specrel).
      end.

      cr_wrk.id_credit_type = 1. /*1- кредит 7-гарантия*/
      cr_wrk.is_credit_line = 0.

      if txb.lon.gua = "CL" then cr_wrk.is_credit_line = 1.
      if txb.lon.clmain <> '' then cr_wrk.is_credit_line = 1.
      if trim(txb.loncon.lcnt) begins "CL-" then cr_wrk.is_credit_line = 1.
      /* name of the beneficiary */
      cr_wrk.begin_date_by_contract = txb.lon.rdt.
      cr_wrk.expire_date_by_contract = txb.lon.duedt.
      cr_wrk.id_currency = v-currency.
      cr_wrk.sum_total_by_contract = txb.lon.opnamt * rates[txb.lon.crc].
      cr_wrk.crediting_rate_by_contract = v-inirate.
      cr_wrk.begin_date_in_fact = v-dt_givefact.
      cr_wrk.sum_given_in_fact = v-sum_givefact.
      cr_wrk.total_sum_given_in_fact = v-total_sum_givefact.
      cr_wrk.crediting_rate_in_fact = txb.lon.prem.
      if v-dt_prolong <> ? then cr_wrk.date_end_of_prolongation = v-dt_prolong.
      cr_wrk.id_cred_object = v-lntgt. /* объект кредитования */
      cr_wrk.id_source_of_finance = 1. /* источник финансирования */
      cr_wrk.id_classification_category = v-stsclass.
      cr_wrk.id_credit_kind_of_payment = v-typeobes.
      cr_wrk.cost_of_guarantee = v-costobes.
      cr_wrk.id_account_current_debt = v-glnum[1].
      if bilance[2] > 0 then cr_wrk.id_account_overdue_debt = v-glnum[2]. else cr_wrk.id_account_overdue_debt = 0.
      if bilance[3] > 0 then cr_wrk.id_account_write_off_bal_debt = v-glnum[3]. else cr_wrk.id_account_write_off_bal_debt = 0.
      cr_wrk.rem_current_debt = bilance[1] * rates[txb.lon.crc].
      cr_wrk.rem_overdue_debt = bilance[2] * rates[txb.lon.crc].
      cr_wrk.rem_write_off_balance_debt = bilance[3] * rates[txb.lon.crc].
      cr_wrk.rem_cr_rate_curr_debt = v-proc[1] * rates[txb.lon.crc].
      cr_wrk.rem_cr_rate_overdue_debt = v-proc[2] * rates[txb.lon.crc].
      cr_wrk.rem_cr_rate_write_off_bal_debt = v-proc[3] * rates[txb.lon.crc].
      cr_wrk.remaining_liability = 0.
      if v-dt_naprosr <> ? then cr_wrk.date_cr_acc_write_off_bal_debt = v-dt_naprosr.
      if v-dt_naspis <> ? then cr_wrk.date_cred_write_off_balance = v-dt_naspis.
      if v-dt_expfact <> ? then cr_wrk.expire_date_in_fact = v-dt_expfact.
      cr_wrk.req_sum_of_provisions = v-provreq.
      cr_wrk.fact_sum_of_provisions = v-provfact.
      cr_wrk.comment1 = substr(v-comment[1],1,100).
      cr_wrk.comment2 = substr(v-comment[2],1,100).


      create lnpr.
       lnpr.lon = txb.lon.lon.
       lnpr.cif = txb.lon.cif.
       lnpr.n1 = v-provreq.
       lnpr.n2 = v-provfact.
  end. /* if v-usual_credit */

  if v-uo_kik then do:

      cr_wrk.is_natural_person = v-urfiz.
      cr_wrk.bik_main_office = v-bik.
      cr_wrk.bik_filial = v-bikf.
      cr_wrk.data_rep = dat.
      cr_wrk.contract_number = ns_check(txb.loncon.lcnt).
      cr_wrk.contract_date = txb.lon.rdt.

      if v-urfiz = 1 then do:

            if txb.cif.bin <> '' then cr_wrk.rnn = txb.cif.bin.
            else cr_wrk.rnn = txb.cif.jss.
            cr_wrk.last_name = v-lastname.
            cr_wrk.first_name = v-firstname.
            cr_wrk.middle_name = v-middlename.
            if trim(txb.cif.addr[1]) <> '' then cr_wrk.address = ns_check(trim(txb.cif.addr[1])). else cr_wrk.address = ns_check(trim(txb.cif.addr[2])).
            cr_wrk.id_region = id_obl.
            if txb.cif.geo = "021" then cr_wrk.is_resident = 1. else cr_wrk.is_resident = 0.
            if txb.cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.
            cr_wrk.is_small_enterprise = v-small_en.
            cr_wrk.id_otrasl = 60.
            cr_wrk.id_special_rel_with_bank = integer(v-specrel).

      end.
      else do:
            if txb.cif.bin <> '' then cr_wrk.rnn = txb.cif.bin.
            else cr_wrk.rnn = txb.cif.jss.
            cr_wrk.okpo = v-okpo.
            cr_wrk.name = ns_check(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
            if txb.cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
            if txb.cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.
            if num-entries(v-bossname,' ') > 0 then cr_wrk.last_name = ns_check(entry(1,v-bossname,' ')).
            if num-entries(v-bossname,' ') > 1 then cr_wrk.first_name = ns_check(entry(2,v-bossname,' ')).
            if num-entries(v-bossname,' ') > 2 then cr_wrk.middle_name = ns_check(entry(3,v-bossname,' ')).
            cr_wrk.is_small_enterprise = v-small_en.
            if id_otrasl <> '' then cr_wrk.id_otrasl = integer(id_otrasl).
            if id_form <> '' then cr_wrk.id_form_law = integer(id_form).
            cr_wrk.id_special_rel_with_bank = integer(v-specrel).
      end.

      cr_wrk.id_credit_type = 10.

      cr_wrk.id_credit_type = 1. /*1- кредит 7-гарантия*/
      cr_wrk.is_credit_line = 0.

      if txb.lon.gua = "CL" then cr_wrk.is_credit_line = 1.
      if txb.lon.clmain <> '' then cr_wrk.is_credit_line = 1.
      if trim(txb.loncon.lcnt) begins "CL-" then cr_wrk.is_credit_line = 1.

      cr_wrk.name_beneficiary = "КИК".
      cr_wrk.begin_date_by_contract = txb.lon.rdt.
      cr_wrk.expire_date_by_contract = txb.lon.duedt.
      cr_wrk.id_currency = v-currency.
      cr_wrk.sum_total_by_contract = txb.lon.opnamt * rates[txb.lon.crc].
      cr_wrk.id_classification_category = v-stsclass.
      cr_wrk.id_credit_kind_of_payment = v-typeobes. /* ??? */
      cr_wrk.cost_of_guarantee = v-costobes.
      cr_wrk.remaining_liability = bilance_kik * rates[txb.lon.crc].
      cr_wrk.comment1 = v-comment[1].
      cr_wrk.comment2 = v-comment[2].

  end. /* if v-uo_kik */

  numcred = numcred + 1.
  if p-cif2 <> p-cif1 then do:
    p-cif2 = p-cif1.
    if v-urfiz = 0 then numur = numur + 1.
    else numfiz = numfiz + 1.
  end.

  /*
  hide message no-pause.
  message " " + s-bank + " -  Кредитов: " numcred "   Юр.лиц: " numur "   Физ.лиц: " numfiz " ".
  */
end. /*for each lon*/

/*************************************************************************************************/

    def buffer b-cif for txb.cif.
    v-urfiz = -1.
                           /* не конкурсная/тендерная                залог - не деньги */
    for each txb.garan where txb.garan.gtype <> 1 and integer(trim(txb.garan.obes)) <> 3 and txb.garan.dtfrom < dat and txb.garan.dtto >= dt1 :
     find b-cif where b-cif.cif = txb.garan.cif no-lock no-error.
     if avail b-cif then
     do:
       if b-cif.type = 'p' then v-urfiz = 1. /*fiz*/
       if b-cif.type = 'b' then do:
            if lookup(string(b-cif.cgr),'403,405,605,501') <> 0 then v-urfiz = 1.
            else v-urfiz = 0. /*ur*/
       end.

          create cr_wrk.

		  v-small_en = 0.
		  find first txb.sub-cod where txb.sub-cod.acc = b-cif.cif and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lneko" no-lock no-error.
		  if avail txb.sub-cod then do:
		    if txb.sub-cod.ccode = '72' or txb.sub-cod.ccode = '72.1' then v-small_en = 1.
		  end.



		  case v-urfiz:
		   when 0 then do: /*юрики*/
			  v-bossname = ''.
			  cr_wrk.okpo = trim(b-cif.ssn).
			  find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = b-cif.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
			  if avail txb.sub-cod then v-bossname = GTrim(txb.sub-cod.rcode).


			  cr_wrk.name = ns_check(trim(b-cif.prefix) + " " + trim(b-cif.name)).
              if b-cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
              if b-cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.
              if num-entries(v-bossname,' ') > 0 then cr_wrk.last_name = ns_check(entry(1,v-bossname,' ')).
              if num-entries(v-bossname,' ') > 1 then cr_wrk.first_name = ns_check(entry(2,v-bossname,' ')).
              if num-entries(v-bossname,' ') > 2 then cr_wrk.middle_name = ns_check(entry(3,v-bossname,' ')).

			  i = lookup(trim(b-cif.prefix),form_tex).
			  if i > 0 then id_form = trim(entry(i,form_afn)).
			  if id_form = '' then do:
			    message "Не найден код формы собственности!" view-as alert-box buttons ok.
			    id_form = "103".
			  end.


			  find first txb.sub-cod where txb.sub-cod.acc = b-cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" no-lock no-error.
			  if avail txb.sub-cod then do:
			    i = lookup(txb.sub-cod.ccode,otrasl_tex).
			    if i > 0 then id_otrasl = trim(entry(i,otrasl_afn)).
			  end.
			  if id_otrasl = '' then do:
			    message "Не найден код отрасли экономики!" view-as alert-box buttons ok.
			    id_otrasl = "-1".
			  end.


              if id_form <> '' then cr_wrk.id_form_law = integer(id_form).
              if id_otrasl <> '' then cr_wrk.id_otrasl = integer(id_otrasl).

		   end.
		   when 1 then do: /*физики*/
			  tmp_s = GTrim(b-cif.name).
		      if v-small_en = 0 then do:
		        v-lastname = ns_check(entry(1,tmp_s,' ')).
		        v-firstname = ns_check(entry(2,tmp_s,' ')).
		        if num-entries(tmp_s,' ') > 2 then v-middlename = ns_check(entry(3,tmp_s,' ')).
		        else v-middlename = "".
		      end.
		      else do:
		        v-lastname = trim(b-cif.prefix) + " " + trim(tmp_s).
		        v-firstname = "О".
		        v-middlename = ''.
		      end.

              cr_wrk.last_name = v-lastname.
              cr_wrk.first_name = v-firstname.
              cr_wrk.middle_name = v-middlename.
              if trim(b-cif.addr[1]) <> '' then cr_wrk.address = ns_check(trim(b-cif.addr[1])).
              else cr_wrk.address = ns_check(trim(b-cif.addr[2])).
              cr_wrk.id_region = id_obl.
              if b-cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
              if b-cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.

              cr_wrk.id_otrasl = 60.

		   end.
		  end case.

          v-specrel = "171".
		  if b-cif.bin <> '' then find first prisv where prisv.rnn = b-cif.bin no-lock no-error.
          else find first prisv where caps(prisv.name) = caps(b-cif.name)  no-lock no-error.
		  if avail prisv then do:
		    i = lookup(trim(prisv.specrel),specrel_tex).
		    if i > 0 then v-specrel = trim(entry(i,specrel_afn)).
		  end.

		  /*case txb.garan.crc:
		    when 1 then v-currency = 4.
		    when 2 then v-currency = 3.
		    when 3 then v-currency = 112.
		  end case.*/
          i = lookup(string(txb.garan.crc),v-spcrc1).
          if i > 0 then v-currency = int(entry(i,v-spcrc2)).
          else do:
            v-currency = ?.
            message txb.garan.garan ": не определяется код валюты для Кредитного регистра" view-as alert-box buttons ok.
          end.

            if b-cif.bin <> '' then cr_wrk.rnn = b-cif.bin.
            else cr_wrk.rnn = b-cif.jss.
		  /*cr_wrk.rnn = b-cif.jss.*/
          cr_wrk.id_credit_type = 7. /*7-гарантия*/
          cr_wrk.is_small_enterprise = v-small_en.
          cr_wrk.id_special_rel_with_bank = integer(v-specrel).
	      cr_wrk.is_natural_person = v-urfiz.
	      cr_wrk.bik_main_office = v-bik.
	      cr_wrk.bik_filial = v-bikf.
	      cr_wrk.data_rep = dat.
	      cr_wrk.contract_number = txb.garan.garnum.
	      cr_wrk.contract_date = txb.garan.dtfrom. /*Дата договора*/
          cr_wrk.begin_date_by_contract = txb.garan.dtfrom. /*Дата выдачи по условиям договора*/
          cr_wrk.expire_date_by_contract = txb.garan.dtto. /*Дата погашения по условиям договора*/
          cr_wrk.id_currency = v-currency. /* Валюта выдачи */

          find first txb.jh where txb.jh.jh = txb.garan.jh no-lock no-error.
          if avail txb.jh then
           do:
           cr_wrk.begin_date_in_fact = txb.jh.jdt.  /*Дата фактической выдачи    txb.garan.dtfrom.*/
          end.
          else do:
            message "Не найдена проводка " txb.garan.jh " в таблице jh !" view-as alert-box.
          end.

          cr_wrk.id_classification_category = 1. /*Классиф. категория*/

          if integer(txb.garan.obes) = 6 then cr_wrk.id_credit_kind_of_payment = 7.
          else cr_wrk.id_credit_kind_of_payment = integer(txb.garan.obes). /*Займ/УО по виду обеспечения*/

          cr_wrk.sum_total_by_contract = txb.garan.sumtreb.  /* sum Общая сумма по условиям договора*/
          cr_wrk.name_beneficiary = txb.garan.naim. /* Наименование бенефициара*/
          cr_wrk.cost_of_guarantee = txb.garan.sumzalog. /* Стоимость обеспечения */


        /*-------   Остаток условного обязательства  cr_wrk.remaining_liability   ---------*/
         find first txb.aaa where txb.aaa.aaa = txb.garan.garan no-lock no-error.
         if avail txb.aaa then
         do:
           find first txb.trxbal where txb.trxbal.acc = txb.aaa.aaa and txb.trxbal.level = 7 no-lock no-error.
           if avail txb.trxbal then
           do:
             find txb.trxlevgl where txb.trxlevgl.gl eq txb.aaa.gl and txb.trxlevgl.subled eq txb.trxbal.subled and txb.trxlevgl.level eq txb.trxbal.level no-lock no-error.
             find txb.gl where txb.gl.gl eq txb.trxlevgl.glr no-lock no-error.
             if avail txb.gl then
             do:
               if txb.gl.type eq "A" or txb.gl.type eq "E" then cr_wrk.remaining_liability = txb.trxbal.dam - txb.trxbal.cam.
               else cr_wrk.remaining_liability = txb.trxbal.cam - txb.trxbal.dam.
               find txb.sub-cod where txb.sub-cod.sub eq "gld" and txb.sub-cod.d-cod eq "gldic" and txb.sub-cod.acc eq string(txb.trxlevgl.glr) no-lock no-error.
			   if available txb.sub-cod and txb.sub-cod.ccode eq "01" then
			    cr_wrk.remaining_liability = - cr_wrk.remaining_liability.
			 end.
             else message "Нет записи в таблице GL" view-as alert-box.
           end.
           else message "Нет записи в таблице TRXBAL" view-as alert-box.
         end.
         else message "Нет записи в таблице AAA" view-as alert-box.
         /*----------                                                             -----------*/



         if cr_wrk.remaining_liabilit = 0 then  /* дата фактического погашения */
         do:
           find last txb.jl where txb.jl.sub = "cif" and txb.jl.acc = txb.garan.garan and txb.jl.jdt < dat and txb.jl.lev = 7 and txb.jl.dc = "c" no-lock no-error.
           if avail txb.jl then cr_wrk.expire_date_in_fact = txb.jl.jdt.
         end.

       garcount = garcount + 1.
     end.
     else do:
       message "Не найден клиент " txb.garan.cif "в таблице CIF"  view-as alert-box.
     end.
   end.

/* аккредитивы и гарантии из модуля ТФ */
    v-urfiz = -1.

    for each lc where lc.bank = s-bank and lc.lctype = 'i' and lookup(lc.lcsts,'fin,cls,cln') > 0 no-lock:
        if lc.lcsts <> 'fin' then do:
            find last lcsts
            where     lcsts.lcnum = lc.lc
            and       lcsts.sts   = lc.lcsts
            no-lock no-error.
            if avail lcsts and lcsts.whn < dt1 then next.
        end.

        if lc.lc begins 'pg' then v-gar = yes. else v-gar = no.

        find first lch where lch.lc = lc.lc and lch.kritcode = 'cover' no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            message "Не найден реквизит Covered/Uncovered для " lc.lc "!" view-as alert-box.
            next.
        end.
        if v-gar and lch.value1 = '0' then next. /* гарантии только непокрытые */
        v-cover = lch.value1.

        v-cod = if v-gar then 'Date' else 'DtIs'.
        find first lch where lch.lc = lc.lc and lch.kritcode = v-cod no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            find first lckrit where lckrit.datacode = v-cod and lckrit.lctype = 'i' no-lock no-error.
            v-name = if avail lckrit then lckrit.dataname else ''.
            message "Не найден реквизит " v-name " для " lc.lc "!" view-as alert-box.
            next.
        end.
        if date(lch.value1) >= dat then next.
        v-dt1 = date(lch.value1).

        find first lch where lch.lc = lc.lc and lch.kritcode = 'DtExp' no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            message "Не найден реквизит Date of Expiry для " lc.lc "!" view-as alert-box.
            next.
        end.

        find last lcamendh where lcamendh.lc = lc.lc and lcamendh.kritcode = 'NewDtEx' and lcamendh.value1 ne '' no-lock no-error.
        if avail lcamendh then v-dt2 = date(lcamendh.value1).
        else v-dt2 = date(lch.value1).

        /*if v-dt2 < dt1 then next.*/

        /* подсчет остатка */
        v-sum1 = 0. v-sum2 = 0.
        find first lch where lch.lc = lc.lc and lch.kritcode = 'amount' no-lock no-error.
        if not avail lch then message "Не найден реквизит Amount для " lc.lc "!" view-as alert-box.
        else v-sum1 = decimal(lch.value1).

        find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
        if avail lch and lch.value1 ne '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then v-sum1 = v-sum1 + (v-sum1 * (v-per / 100)).
        end.

        /* amendment */
        if v-gar then
        for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.dacc = '605562' or  lcamendres.dacc = '655562') and lcamendres.jh > 0 no-lock:
            find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
            if not avail txb.jh then message "Не найдена проводка " lcamendres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
            else do:
                if txb.jh.jdt >= dat then next.
                if lcamendres.dacc = '605562' then v-sum1 = v-sum1 + lcamendres.amt.
                else v-sum1 = v-sum1 - lcamendres.amt.
            end.
        end.
        else
        for each lcamendres where lcamendres.lc = lc.lc and (lcamendres.levD = 23 or  lcamendres.levD = 24 or lcamendres.levC = 23 or  lcamendres.levC = 24) and lcamendres.jh > 0 no-lock:
            find first txb.jh where txb.jh.jh = lcamendres.jh no-lock no-error.
            if not avail txb.jh then message "Не найдена проводка " lcamendres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
            else do:
                if txb.jh.jdt >= dat then next.
                if lcamendres.levD = 23 or lcamendres.levD = 24 then v-sum1 = v-sum1 + lcamendres.amt.
                else v-sum1 = v-sum1 - lcamendres.amt.
            end.
        end.
        v-sum2 = v-sum1.
        /* expire, cancel */
        if v-gar then find first lceventres where lceventres.lc = lc.lc and (lceventres.event = 'exp' or lceventres.event = 'cnl') and lceventres.number = 1 and lceventres.dacc = '655562' and lceventres.jh > 0 no-lock no-error.
        else find first lceventres where lceventres.lc = lc.lc and (lceventres.event = 'exp' or lceventres.event = 'cnl') and lceventres.number = 1 and (lceventres.levC = 23 or  lceventres.levC = 24) and lceventres.jh > 0 no-lock no-error.
        if avail lceventres then do:
            find first txb.jh where txb.jh.jh = lceventres.jh no-lock no-error.
            if not avail jh then message "Не найдена проводка " lceventres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
            else if txb.jh.jdt >= dt1 and txb.jh.jdt <= dt2 then assign v-sum2 = 0 v-dt3 = lceventres.jdt.
        end.
        if v-sum2 <> 0 then do:
            /* payment */
            if v-gar then do:
                for each lcpayres where lcpayres.lc = lc.lc and lcpayres.dacc = '655562' and lcpayres.cacc = '605562' and lcpayres.jh > 0 no-lock:
                    find first txb.jh where txb.jh.jh = lcpayres.jh no-lock no-error.
                    if not avail jh then message "Не найдена проводка " lcpayres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
                    else do:
                        if txb.jh.jdt >= dat then next.
                        assign v-sum2 = v-sum2 - lcpayres.amt v-dt3 = lcpayres.jdt.
                        find first lcpayh where lcpayh.lc = lc.lc and lcpayh.lcpay = lcpayres.lcpay and lcpayh.kritcode = 'DtNar' no-lock no-error.
                        if avail lcpayh and lcpayh.value1 ne '' then v-dt3 = date(lcpayh.value1).
                    end.
                end.
            end.
            else
            for each lcpayres where lcpayres.lc = lc.lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
                find first txb.jh where txb.jh.jh = lcpayres.jh no-lock no-error.
                if not avail jh then message "Не найдена проводка " lcpayres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
                else do:
                    if txb.jh.jdt >= dat then next.
                    assign v-sum2 = v-sum2 - lcpayres.amt v-dt3 = lcpayres.jdt.
                    find first lcpayh where lcpayh.lc = lc.lc and lcpayh.lcpay = lcpayres.lcpay and lcpayh.kritcode = 'DtNar' no-lock no-error.
                    if avail lcpayh and lcpayh.value1 ne '' then v-dt3 = date(lcpayh.value1).
                end.
            end.
            /* event */
            for each lceventres where lceventres.lc = lc.lc and lceventres.event <> 'exp' and lceventres.event <> 'cnl' and (lceventres.dacc = '655561' or lceventres.dacc = '655562' or lceventres.levC = 23 or  lceventres.levC = 24) and lceventres.jh > 0 no-lock.
                find first txb.jh where txb.jh.jh = lceventres.jh no-lock no-error.
                if not avail jh then message "Не найдена проводка " lceventres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
                else do:
                    if txb.jh.jdt >= dat then next.
                    assign v-sum2 = v-sum2 - lceventres.amt.
                end.
            end.
        end.
        if v-sum2 = 0 and v-dt3 < dt1 then next.

        v-cod = if v-gar then 'PrCode' else 'ApplCode'.
        find first lch where lch.lc = lc.lc and lch.kritcode = v-cod no-lock no-error.
        if not avail lch or lch.value1 = '' then do:
            find first lckrit where lckrit.datacode = v-cod and lckrit.lctype = 'i' no-lock no-error.
            v-name = if avail lckrit then lckrit.dataname else ''.
            message "Не найден реквизит " v-name " для " lc.lc "!" view-as alert-box.
            next.
        end.
        v-urfiz = 0.
        find b-cif where b-cif.cif = lch.value1 no-lock no-error.
        if avail b-cif then
        do:
            if b-cif.type = 'p' then v-urfiz = 1. /*fiz*/
            if b-cif.type = 'b' then do:
                if lookup(string(b-cif.cgr),'403,405,605,501') <> 0 then v-urfiz = 1.
                else v-urfiz = 0. /*ur*/
            end.

            create cr_wrk.

			v-small_en = 0.
			find first txb.sub-cod where txb.sub-cod.acc = b-cif.cif and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lneko" no-lock no-error.
			if avail txb.sub-cod then do:
			    if txb.sub-cod.ccode = '72' or txb.sub-cod.ccode = '72.1' then v-small_en = 1.
			end.

            case v-urfiz:
			   when 0 then do: /*юрики*/
				  v-bossname = ''.
				  cr_wrk.okpo = trim(b-cif.ssn).
				  find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = b-cif.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
				  if avail txb.sub-cod then v-bossname = GTrim(txb.sub-cod.rcode).

				  cr_wrk.name = ns_check(trim(b-cif.prefix) + " " + trim(b-cif.name)).
                  if b-cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
                  if b-cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.
                  if num-entries(v-bossname,' ') > 0 then cr_wrk.last_name = ns_check(entry(1,v-bossname,' ')).
                  if num-entries(v-bossname,' ') > 1 then cr_wrk.first_name = ns_check(entry(2,v-bossname,' ')).
                  if num-entries(v-bossname,' ') > 2 then cr_wrk.middle_name = ns_check(entry(3,v-bossname,' ')).

				  i = lookup(trim(b-cif.prefix),form_tex).
				  if i > 0 then id_form = trim(entry(i,form_afn)).
				  if id_form = '' then do:
				    message "Не найден код формы собственности!" view-as alert-box buttons ok.
				    id_form = "103".
				  end.

				  find first txb.sub-cod where txb.sub-cod.acc = b-cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" no-lock no-error.
				  if avail txb.sub-cod then do:
				    i = lookup(txb.sub-cod.ccode,otrasl_tex).
				    if i > 0 then id_otrasl = trim(entry(i,otrasl_afn)).
				  end.
				  if id_otrasl = '' then do:
				    message "Не найден код отрасли экономики!" view-as alert-box buttons ok.
				    id_otrasl = "-1".
				  end.

                  if id_form <> '' then cr_wrk.id_form_law = integer(id_form).
                  if id_otrasl <> '' then cr_wrk.id_otrasl = integer(id_otrasl).
			   end.
			   when 1 then do: /*физики*/
				  tmp_s = GTrim(b-cif.name).
			      if v-small_en = 0 then do:
			        v-lastname = ns_check(entry(1,tmp_s,' ')).
			        v-firstname = ns_check(entry(2,tmp_s,' ')).
			        if num-entries(tmp_s,' ') > 2 then v-middlename = ns_check(entry(3,tmp_s,' ')).
			        else v-middlename = "".
			      end.
			      else do:
			        v-lastname = trim(b-cif.prefix) + " " + trim(tmp_s).
			        v-firstname = "О".
			        v-middlename = ''.
			      end.

                  cr_wrk.last_name = v-lastname.
                  cr_wrk.first_name = v-firstname.
                  cr_wrk.middle_name = v-middlename.
                  if trim(b-cif.addr[1]) <> '' then cr_wrk.address = ns_check(trim(b-cif.addr[1])).
                  else cr_wrk.address = ns_check(trim(b-cif.addr[2])).
                  cr_wrk.id_region = id_obl.
                  if b-cif.geo = "021" then cr_wrk.is_resident =1. else cr_wrk.is_resident =0.
                  if b-cif.geo <> "021" then cr_wrk.id_nonresident_country = 1286.

                  cr_wrk.id_otrasl = 60.
			   end.
			end case.
            v-specrel = "171".
            if b-cif.bin <> '' then find first prisv where prisv.rnn = b-cif.bin no-lock no-error.
            else find first prisv where caps(prisv.name) = caps(b-cif.name)  no-lock no-error.
			if avail prisv then do:
			    i = lookup(trim(prisv.specrel),specrel_tex).
			    if i > 0 then v-specrel = trim(entry(i,specrel_afn)).
			end.

			find first lch where lch.lc = lc.lc and lch.kritcode = 'lccrc' no-lock no-error.
            v-crc = int(lch.value1).
            /*case v-crc:
			    when  1 then v-currency = 4.
			    when  2 then v-currency = 3.
			    when  3 then v-currency = 112.
                when  4 then v-currency = 1.
                when 10 then v-currency = 56.
                otherwise    v-currency = ?.
			end case.*/
            i = lookup(string(v-crc),v-spcrc1).
            if i > 0 then v-currency = int(entry(i,v-spcrc2)).
            else do:
             v-currency = ?.
             message lc.lc ": не определяется код валюты для Кредитного регистра" view-as alert-box buttons ok.
            end.

            if b-cif.bin <> '' then cr_wrk.rnn = b-cif.bin.
            else cr_wrk.rnn = b-cif.jss.
            assign
            cr_wrk.id_credit_type           = if v-gar then 7 else 8 /*7-гарантия*/
            cr_wrk.is_small_enterprise      = v-small_en
            cr_wrk.id_special_rel_with_bank = integer(v-specrel)
	        cr_wrk.is_natural_person        = v-urfiz
	        cr_wrk.bik_main_office          = v-bik
	        cr_wrk.bik_filial               = v-bikf
	        cr_wrk.data_rep                 = dat
	        cr_wrk.contract_number          = lc.lc
	        cr_wrk.contract_date            = v-dt1 /*Дата договора*/
            cr_wrk.begin_date_by_contract   = v-dt1 /*Дата выдачи по условиям договора*/
            cr_wrk.expire_date_by_contract  = v-dt2 /*Дата погашения по условиям договора*/
            cr_wrk.id_currency              = v-currency. /* Валюта выдачи */

            if v-gar then find first lcres where lcres.lc = lc.lc and lcres.dacc = '605562' and lcres.cacc = '655562' and lcres.jh > 0 no-lock no-error.
            else find first lcres where lcres.lc = lc.lc and (lcres.levD = 23 or lcres.levD = 24) and lcres.jh > 0 no-lock no-error.
            if avail lcres then do:
              find first txb.jh where txb.jh.jh = lcres.jh no-lock no-error.
              if avail txb.jh then cr_wrk.begin_date_in_fact = txb.jh.jdt.  /*Дата фактической выдачи*/
              else message "Не найдена проводка " lcres.jh " в таблице jh для " lc.lc "!" view-as alert-box.
            end.
            assign
            cr_wrk.id_classification_category = 1 /*Классиф. категория*/
            cr_wrk.id_credit_kind_of_payment  = if v-gar then 5 else if v-cover = '1' then 5 else 3. /*Займ/УО по виду обеспечения*/

            assign
            cr_wrk.sum_total_by_contract = round(v-sum1 * rates[v-crc],0)  /* Общая сумма по условиям договора*/
            cr_wrk.cost_of_guarantee     = if v-gar then 0 else if v-cover = '1' then 0 else round(v-sum1 * rates[v-crc],0). /* Стоимость обеспечения */

            find first lch where lch.lc = lc.lc and lch.kritcode = 'benef' no-lock no-error.
            if not avail lch then message "Не найден реквизит Beneficiary для " lc.lc "!" view-as alert-box.
            else cr_wrk.name_beneficiary = ns_check(trim(substr(lch.value1,1,35))). /* Наименование бенефициара*/

            cr_wrk.remaining_liability = round(v-sum2 * rates[v-crc],0).

            if cr_wrk.remaining_liabilit = 0 then  /* дата фактического погашения */
            cr_wrk.expire_date_in_fact = v-dt3.

            if v-gar then garcount = garcount + 1.
            else akkrcount = akkrcount + 1.
        end.
     end.

/*************************************************************************************************/

if mesa <> '' then mesa = mesa + " ~n ".
mesa = mesa + s-bank + " -  Кредитов: " + trim(string(numcred,">>>>>>9")) + " Аккредитивов: " + trim(string(akkrcount,">>>>>>9"))  + " Гарантий: " + trim(string(garcount,">>>>>>9")) + "  Юр.лиц: " + trim(string(numur,">>>>>>9")) + "  Физ.лиц: " + trim(string(numfiz,">>>>>>9")).
