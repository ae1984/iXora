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
 * BASES
        BANK COMM TXB
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
        14.01.2009 galina - процентная ставка по договору ищем в анкете, если не нашли в истории и в самом кредите она тоже нулевая
        11/03/2009 madiyar - общая выданная сумма займа = (выд. за отчетный период + до отчетного периода)
        19/04/2010 madiyar - признак связи с банком особыми отношениями определяем из справочника prisv
        16/08/2010 k.gitalov - вместо формирования файлов - заполнение темп таблицы cr_wrk
        19/11/2010 madiyar - изменения по залогам и в определении принадлежности к МСБ (v-small_en)
        17/03/2011 madiyar - обновил соответствие отраслей
        15/07/2011 id00810 - дополнила справочник организационно-правовых форм (полное товарищество)
        16/08/2011 madiyar - остатки показываем на просроченном ОД
        25/12/2012 sayat(id01143) - первоначальное присвоение v-specrel = "171" и исправление справочника связ с БВУ
        18/01/2013 sayat(id01143) - исправлены списки значений specrel_tex и specrel_afn в связи с изменением справочника связи особыми отношениями в АИП Кредитный Регистр
        13/03/2013 sayat(id01143) - ТЗ 1758 поиск связи особыми отношениями по ИИН/БИН, в поле rnn передаем ИИН/БИН (и РНН если ИИН/БИН отсутствует)
*/

def input parameter dat as date no-undo.
def input parameter dt1 as date no-undo.
def input parameter dt2 as date no-undo.

def shared var g-today as date.
def shared var v-bik as char.
def shared var rates as deci extent 20.
def shared var mesa as char.

function ns_check returns character (input parm as character).
  def var v-str as char no-undo.
  v-str = parm.
  if index(v-str,"""") > 0 then v-str = replace(v-str,"""","").
  if index(v-str,"<?") > 0 then v-str = replace(v-str,"<?","").
  if index(v-str,"?>") > 0 then v-str = replace(v-str,"?>","").
  if index(v-str,"<") > 0 then v-str = replace(v-str,"<","").
  if index(v-str,">") > 0 then v-str = replace(v-str,">","").
  if index(v-str,"&") > 0 then v-str = replace(v-str,"&","").
  return (v-str).
end function.

{trim.i}

{credreg.i}
def var p-cif1 like txb.cif.cif.
def var p-cif2 like txb.cif.cif.
def var v-file as char no-undo init "loans".

def var v-sep as char no-undo init "^".
def var s-credtype as char.
def var s-bank as char no-undo.
find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause.
  return.
end.
else s-bank = txb.sysc.chval.

def var v-bikf as char no-undo.
v-bikf = "190501470". /* Всегда берем БИК ЦО */

/*
find first txb where txb.bank = s-bank and txb.consolid no-lock no-error.
if avail txb then v-bikf = txb.mfo.
*/

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
def var v-typeobes as integer no-undo.
def var v-costobes as decimal no-undo.
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
/*
def var specrel_tex as char no-undo init "12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34".
def var specrel_afn as char no-undo init "78,79,80,81,82,83,84,85,98,87,88,89,90,91,92,93,94,95,96,97,100,102,103".
*/
def var specrel_tex as char no-undo init "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50".
def var specrel_afn as char no-undo init "122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171".
/* перечень кодов признака lnshifr для выделения субъектов малого предпринимательства */
def var codelist as char no-undo init "03,04,07,08,11,12,15,16,19,20,23,24".

def var i as integer no-undo.
def var v-sc as char no-undo.
def var numcred as integer no-undo.
def var numfiz as integer no-undo.
def var numur as integer no-undo.

def var tmp_s as char no-undo.

def var v-usual_credit as logical no-undo init no.
def var v-uo_kik as logical no-undo init no.

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

numcred = 0. numur = 0. numfiz = 0. p-cif1 = ''. p-cif2 = ''.


for each txb.lon no-lock break by txb.lon.cif:

  if first-of(txb.lon.cif) then p-cif1 = txb.lon.cif.

  if txb.lon.opnamt = 0 then next.
  if txb.lon.rdt >= dat then next.

  if lookup(string(txb.lon.grp),lst_ur) > 0 then v-urfiz = 0. /* ur */
  else v-urfiz = 1. /* fiz */

  v-reptype = v-urfiz + 1.

  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"1,7,13,14",no,txb.lon.crc,output bilance_per[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1,7,13,14",yes,txb.lon.crc,output bilance_per[2]).
  /*
  run lonbalcrc_txb('lon',txb.lon.lon,dt1,"13,14",no,txb.lon.crc,output bilance_spis[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13,14",yes,txb.lon.crc,output bilance_spis[2]).
  */

  v-usual_credit = (bilance_per[1] + bilance_per[2] + bilance_spis[1] + bilance_spis[2] > 0).

  if not(v-usual_credit) then next.

  v-dt_expfact = ?.
  if bilance_per[2] <= 0 then do:
    find last txb.lonres where txb.lonres.lon = txb.lon.lon and txb.lonres.jdt <= dt2 and (txb.lonres.lev = 1 or txb.lonres.lev = 7) and txb.lonres.dc = "C" no-lock no-error.
    if avail txb.lonres then v-dt_expfact = txb.lonres.jdt.
  end.

  /*
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"1",yes,txb.lon.crc,output bilance[1]).

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"7",yes,txb.lon.crc,output bilance[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"13",yes,txb.lon.crc,output bilance[3]).

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"2",yes,txb.lon.crc,output v-proc[1]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"9",yes,txb.lon.crc,output v-proc[2]).
  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"14",yes,txb.lon.crc,output v-proc[3]).
  */

  find first bank.codfr where bank.codfr.codfr = "lnmko" and bank.codfr.code = substring(s-bank,4,2) + "-" + txb.lon.lon no-lock no-error.
  if avail bank.codfr then bilance[2] = deci(bank.codfr.name[2]).
  else do:
    /* message txb.lon.cif + ' ' + txb.lon.lon + ' - не найдена запись в справочнике с оценочной стоимостью!' view-as alert-box error. */
    next.
  end.
  assign bilance[1] = 0
         bilance[3] = 0
         v-proc[1] = 0
         v-proc[2] = 0
         v-proc[3] = 0.

  if bilance[1] + bilance[2] <= 0 then next.

  find txb.loncon where txb.loncon.lon = txb.lon.lon no-lock no-error.
  find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.

  v-okpo = ''. id_otrasl = ''. id_form = ''.

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

  case txb.lon.crc:
    when 1 then v-currency = 4.
    when 2 then v-currency = 3.
    when 3 then v-currency = 112.
  end case.

  find txb.ln%his where txb.ln%his.lon = txb.lon.lon and txb.ln%his.stdat = txb.lon.rdt no-lock no-error.
  if avail txb.ln%his then v-inirate = txb.ln%his.intrate.
  else v-inirate = txb.lon.prem.

  if v-inirate  = 0 then do:
     if txb.loncon.lcnt matches "*ДК*" then s-credtype = '6'.
     if txb.loncon.lcnt matches "*ПК*" then s-credtype = '7'.
     if txb.loncon.lcnt matches "*ЛК*" then s-credtype = '5'.
     find pkanketa where pkanketa.bank = s-bank and pkanketa.credtype = s-credtype and pkanketa.ln = integer(entry(3,loncon.lcnt,'/')) no-lock no-error.
     if avail pkanketa  then v-inirate = pkanketa.rateq.
  end.

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

  /*
  v-lntgt = 0.
  find first txb.sub-cod where txb.sub-cod.acc = txb.lon.lon and txb.sub-cod.sub = "LON" and txb.sub-cod.d-cod = "lntgt" no-lock no-error.
  if avail txb.sub-cod then do:
    if txb.sub-cod.ccode <> "msc" then do:
      v-lntgt = integer(txb.sub-cod.ccode) - 9.
      if txb.sub-cod.ccode = "17" then v-lntgt = 117.
      if txb.sub-cod.ccode = "20" then v-lntgt = 8.
    end.
  end.
  if v-lntgt = 0 then do:
    message s-bank + " " + txb.lon.lon + ": object is not defined" view-as alert-box buttons ok.
    v-lntgt = 6.
  end.
  */
  v-lntgt = 6.

  /*
  v-stsclass = 0. v-provreq = 0. v-provfact = 0.
  find last txb.lonhar where txb.lonhar.lon = txb.lon.lon and txb.lonhar.fdt <= dt2 no-lock no-error.
  if not avail txb.lonhar then find last txb.lonhar where txb.lonhar.lon = txb.lon.lon no-lock no-error.
  if avail txb.lonhar then do:
    case txb.lonhar.lonstat:
      when 1 then v-stsclass = 1.
      otherwise v-stsclass = txb.lonhar.lonstat + 1.
    end case.

    find first txb.lonstat where txb.lonstat.lonstat = txb.lonhar.lonstat no-lock no-error.
    v-provreq = (bilance[1] + bilance[2]) * rates[lon.crc] * txb.lonstat.prc / 100.

  end.
  else message txb.lon.lon + ": classification status is not defined" view-as alert-box buttons ok.

  run lonbalcrc_txb('lon',txb.lon.lon,dt2,"3,6",yes,1,output v-provfact).
  v-provfact = - v-provfact.
  */
  v-stsclass = 8. v-provreq = bilance[1] + bilance[2]. v-provfact = bilance[1] + bilance[2].

  /*
  v-costobes = 0. v-maxcost = -1. v-typeobes = 0.
  for each txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon no-lock:
    if txb.lonsec1.lonsec = 5 then next.
    v-costobes = v-costobes + txb.lonsec1.secamt * rates[lonsec1.crc].
    if txb.lonsec1.secamt * rates[lonsec1.crc] > v-maxcost then do:
      v-typeobes = txb.lonsec1.lonsec.
      v-maxcost = txb.lonsec1.secamt * rates[lonsec1.crc].
    end.
  end.
  if v-typeobes = 6 then v-typeobes = 7. -- не совпадают гарантии и поручительства --
  if v-typeobes = 0 then v-typeobes = 5. -- беззалоговые (бланковые) кредиты --

  if (v-typeobes <> 5) and (v-costobes = 0) then do:
    find first txb.lonsec1 where txb.lonsec1.lon = txb.lon.lon and txb.lonsec1.lonsec = v-typeobes no-lock no-error.
    if avail txb.lonsec1 then v-comment[1] = trim(txb.lonsec1.prm).
  end.
  */
  v-costobes = 0. v-maxcost = 0. v-typeobes = 5.

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
  /*ОД*/      v-gl[1] = integer(substring(string(txb.lon.gl),1,4) + if txb.cif.geo = "021" then "1" else "2" + if v-urfiz = 0 then "7" else "9" + if txb.lon.crc = 1 then "1" else "2").
  /*просрОД*/ v-gl[2] = integer("1424" + if cif.geo = "021" then "1" else "2" + if v-urfiz = 0 then "7" else "9" + if txb.lon.crc = 1 then "1" else "2").
  /*списОД*/  v-gl[3] = 7130000.
  */

  v-gl = 0. v-glnum = 0.
  v-sc = ''.
  if txb.cif.geo = "021" then v-sc = v-sc + "1". else v-sc = v-sc + "2".
  if v-urfiz = 0 then v-sc = v-sc + "7". else v-sc = v-sc + "9".
  if txb.lon.crc = 1 then v-sc = v-sc + "1". else v-sc = v-sc + "2".

  v-gl[1] = integer(substring(string(txb.lon.gl),1,4) + v-sc).
  v-gl[2] = integer("1424" + v-sc).

  /*
  message string(v-gl[1]) + " " + string(v-gl[2]) view-as alert-box buttons ok.
  message string(v-glnum[1]) + " " + string(v-glnum[2]) view-as alert-box buttons ok.
  */

  v-glnum[3] = 831.

  do i = 1 to 2:
    case v-gl[i]:
      when 1407171 then v-glnum[i] = 385.
      when 1407172 then v-glnum[i] = 386.
      when 1407191 then v-glnum[i] = 391.
      when 1407192 then v-glnum[i] = 392.
      when 1411171 then v-glnum[i] = 947.
      when 1411172 then v-glnum[i] = 475.
      when 1411191 then v-glnum[i] = 480.
      when 1411192 then v-glnum[i] = 948.
      when 1411271 then v-glnum[i] = 491.
      when 1411272 then v-glnum[i] = 492.
      when 1411291 then v-glnum[i] = 496.
      when 1411292 then v-glnum[i] = 497.
      when 1417171 then v-glnum[i] = 507.
      when 1417172 then v-glnum[i] = 508.
      when 1417191 then v-glnum[i] = 513.
      when 1417192 then v-glnum[i] = 514.
      when 1417271 then v-glnum[i] = 525.
      when 1417272 then v-glnum[i] = 526.
      when 1417291 then v-glnum[i] = 531.
      when 1417292 then v-glnum[i] = 532.
      when 1424171 then v-glnum[i] = 697.
      when 1424172 then v-glnum[i] = 698.
      when 1424191 then v-glnum[i] = 701.
      when 1424192 then v-glnum[i] = 702.
      when 1424271 then v-glnum[i] = 713.
      when 1424272 then v-glnum[i] = 953.
      when 1424291 then v-glnum[i] = 718.
      when 1424292 then v-glnum[i] = 719.
      when 7130000 then v-glnum[i] = 831.

      when 1401171 then v-glnum[i] = 257.
      when 1401172 then v-glnum[i] = 256.
      when 1401191 then v-glnum[i] = 262.
      when 1401192 then v-glnum[i] = 263.
      when 1401271 then v-glnum[i] = 274.
      when 1401272 then v-glnum[i] = 275.
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
  /*
  if v-urfiz = 0 then do:
    find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.lon.cif and txb.sub-cod.d-cod = "clnchf" no-lock no-error.
    if avail txb.sub-cod then v-bossname = GTrim(txb.sub-cod.rcode).
  end.
  */

  if v-urfiz = 1 then do:
    tmp_s = GTrim(txb.cif.name).
    if v-small_en = 0 then do:
      v-lastname = ns_check(entry(1,tmp_s,' ')).
      v-firstname = ns_check(entry(2,tmp_s,' ')).
      if num-entries(tmp_s,' ') > 2 then v-middlename = ns_check(entry(3,tmp_s,' ')).
      else v-middlename = "".
    end.
    else do:
      v-lastname = trim(txb.cif.prefix) + " " + trim(tmp_s).
      v-firstname = "О".
      v-middlename = ''.
    end.
  end.



 create cr_wrk.

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
          if txb.lon.gua = "CL" then cr_wrk.is_credit_line = 1. else cr_wrk.is_credit_line = 0.
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


     /*
      put stream rep unformatted
        v-urfiz v-sep /* повторяем для regimport'a */
        v-bik v-sep
        v-bikf v-sep
        v-reptype v-sep
        replace(string(dat,"99/99/9999"),'/','.') v-sep
        ns_check(txb.loncon.lcnt) v-sep
        replace(string(txb.lon.rdt,"99/99/9999"),'/','.') v-sep
        v-urfiz v-sep.

      put stream rep unformatted
        txb.cif.jss v-sep
        v-lastname v-sep
        v-firstname v-sep
        v-middlename v-sep
        if trim(txb.cif.addr[1]) <> '' then ns_check(trim(txb.cif.addr[1])) else ns_check(trim(txb.cif.addr[2])) v-sep
/*        "id_region=""-1"" "  */
        id_obl v-sep
        if txb.cif.geo = "021" then "1" else "0" v-sep
        if txb.cif.geo <> "021" then "1286" else "" v-sep
        v-small_en v-sep
        "60" v-sep /* отрасль - была 60, теперь пустая */ /* вернул обратно */
        v-specrel v-sep.

      put stream rep unformatted
          1 v-sep
          if txb.lon.gua = "CL" then "1" else "0" v-sep
          "" v-sep /* name of the beneficiary */
          replace(string(txb.lon.rdt,"99/99/9999"),'/','.') v-sep
          replace(string(txb.lon.duedt,"99/99/9999"),'/','.') v-sep
          v-currency v-sep
          trim(string(txb.lon.opnamt * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          trim(string(v-inirate,">>9.99")) v-sep
          replace(string(v-dt_givefact,"99/99/9999"),'/','.') v-sep
          trim(string(v-sum_givefact,">>>>>>>>>>>9.99")) v-sep
          trim(string(v-total_sum_givefact,">>>>>>>>>>>9.99")) v-sep
          trim(string(txb.lon.prem,">>9.99")) v-sep
          if v-dt_prolong <> ? then replace(string(v-dt_prolong,"99/99/9999"),'/','.') else "" v-sep
          v-lntgt v-sep /* объект кредитования */
          1 v-sep /* источник финансирования */
          v-stsclass v-sep
          v-typeobes v-sep
          trim(string(v-costobes,">>>>>>>>>>>9.99")) v-sep
          /*if (v-dt_expfact <> ?) or (bilance[1] > 0) then string(v-glnum[1]) else '' v-sep*/
          string(v-glnum[1]) v-sep
          if bilance[2] > 0 then string(v-glnum[2]) else '' v-sep
          if bilance[3] > 0 then string(v-glnum[3]) else '' v-sep
          trim(string(bilance[1] * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          trim(string(bilance[2] * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          trim(string(bilance[3] * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          trim(string(v-proc[1] * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          trim(string(v-proc[2] * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          trim(string(v-proc[3] * rates[txb.lon.crc],">>>>>>>>>>>9.99")) v-sep
          "0.00" v-sep
          if v-dt_naprosr <> ? then replace(string(v-dt_naprosr,"99/99/9999"),'/','.') else "" v-sep
          if v-dt_naspis <> ? then replace(string(v-dt_naspis,"99/99/9999"),'/','.') else "" v-sep
          if v-dt_expfact <> ? then replace(string(v-dt_expfact,"99/99/9999"),'/','.') else "" v-sep
          trim(string(v-provreq,">>>>>>>>>>>9.99")) v-sep
          trim(string(v-provfact,">>>>>>>>>>>9.99")) v-sep
          "" v-sep
          "" skip.
          */

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

/*
output stream rep close.
unix silent value("scp -q " + v-file + "_" + s-bank + ".rgl Administrator@`askhost`:c://programs//regimport//in;rm *.rgl").
*/

if mesa <> '' then mesa = mesa + " ~n ".
mesa = mesa + s-bank + " -  Кредитов: " + trim(string(numcred,">>>>>>9")) + "  Юр.лиц: " + trim(string(numur,">>>>>>9")) + "  Физ.лиц: " + trim(string(numfiz,">>>>>>9")).
