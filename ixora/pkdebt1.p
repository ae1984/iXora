/* pkdebt1.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Должники на контроле
 * RUN

 * CALLER
    pkdebts.p
 * SCRIPT

 * INHERIT

 * MENU
        4-14-6
 * AUTHOR
        01.02.2004 nadejda
 * CHANGES
        05.04.2004 tsoy перенес работу с письмами
        07.04.2004 tsoy изменил дату погашения на дату ежемесчного расчета
        12.04.2004 tsoy Добавил сохранение курсора в browse
        26.04.2004 tsoy Сохранение меток писем для создания
        15.06.2004 nadejda - обрезание пробелов в параметрах поиска, а то не ищется по фамилии, если ее писать на строке не с начала
        25/06/2004 madiyar - ведомость формируется одна на все типы писем
        13/10/2005 madiyar - добавилось поле balcom
        16/05/2006 madiyar - добавил статус "Z" - списанные за баланс
        18/05/2006 madiyar - в ведомости не выводились все письма, исправил
        02/08/2006 madiyar - добавил "КПро" (кол-во просрочек)
        03/10/2006 madiyar - в вызов pkletter** добавил параметр с суммой долга по комиссии
        17/11/06 Natalya D. - добавлен учет сумм на 4 и 5 уровнях.
        13/09/2007 madiyar - добавил "ДН%" (кол-во дней просрочки по процентам)
        01/04/2008 madiyar - в общую сумму долга 4 и 5 уровни добавлять не надо, они уже сидят в просроченных %% и штрафах
        26/08/2008 madiyar - несколько задолжников не отображались, исправил
        11.11.2008 galina - убрала передачу параметра процедуре pkprtgraf
        08/09/2009 galina - добавила СЗ на рефинансирование, реструктуризацию, списание пени
        15/09/2009 galina - выводим фактические дни просрочки процентов
        12/10/2009 galina - поправила вывод ФИО супруги/супруга
        15/10/2009 galina - перенесла формирование СЗ в пункт 3.1.1 Кредитные операции
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
        28/10/2010 madiyar - 788000 -> 818000
        11/07/2011 kapar - zz9 -> zzz9
*/

{mainhead.i}
{pk.i}

{sysc.i}

def var v-credtype as char no-undo.

def var j as integer no-undo.
def var r AS ROWID no-undo.
def var stat AS LOGICAL no-undo.
def var v-lon like lon.lon no-undo.

def var new_ved as logical no-undo.


def new shared var s-cif like cif.cif.
def var v-days1 as integer no-undo format "zzz9" init 0.
def var v-days2 as integer no-undo format "zzz9" init 9999.
def var v-limit1 as decimal no-undo init 0.
def var v-limit2 as decimal no-undo init 999999999.
def var v-parsts as char no-undo init ''.
def var v-sts as character no-undo initial "A".

define variable v-checkdt1 as date no-undo.
define variable v-checkdt2 as date no-undo.
def var v-days_od as integer no-undo.

define variable v-duedt1 as inte no-undo format "z9" init 0.
define variable v-duedt2 as inte no-undo format "z9" init 31 .

def new shared var s-bookcod as char init "letters".
def new shared var s-codemask as char init "lndolg*".
def new shared var s-filename as char init "letter".
def new shared var s-paramnom as char init "pkletn".

def var v-vednom as integer no-undo.
def var v-days as integer no-undo format "zzz9" init 30.

def var v-rid as rowid no-undo.
def var i as integer no-undo.
def var v-ans as logical no-undo.
def stream r-lst.
DEFINE VARIABLE method-return AS LOGICAL.
def var v-char as char no-undo.

def var v-cifc as char no-undo.
def var v-cifn as char no-undo.
def var v-sumd as deci no-undo.

def shared temp-table t-pkdebt like pkdebt
  field name      as   char
  field checkdt   as   date
  field yessendlt as   char
  field bal1      like lon.opnamt   /* основной долг */
  field bal2      like lon.opnamt   /* проценты      */
  field balpen    like lon.opnamt   /* штрафы        */
  field balcom    like lon.opnamt   /* комиссия за вед. счета */
  field bal3      like lon.opnamt   /* общая сумма задолженности */
  field balz1     like lon.opnamt   /* списанный ОД */
  field balz2     like lon.opnamt   /* списанные % */
  field balzpen   like lon.opnamt   /* списанные штрафы */
  field bal4      like lon.opnamt   /* 4уровень*/
  field bal5      like lon.opnamt   /* 5уровень*/
  field balmon    like lon.opnamt
  field aaabal    like lon.opnamt
  field crc       like lon.crc
  field lastlt    as   char
  field lastltdt  as   date
  field roll      as   integer
  field stype     as   char
  field duedt     like lon.duedt
  field lgrfdt    as date
  field expdt     as date
  field eday      as integer
  field prkol     as integer.

/* def new shared temp-table t-pk_debt like t-pkdebt. */
def new shared temp-table t-debt like t-pkdebt
  field days_prc as integer.

def frame f-param
    v-limit1 label "Сумма задолженности: С" format ">>>,>>>,>>9.99" validate (v-limit1 >= 0, " Неверная сумма!")
    v-limit2 label "ПО" format ">>>,>>>,>>9.99" validate (v-limit2 >= 0, " Неверная сумма!") " " skip
    v-days1 label "Дни просрочки: С"
    v-days2 label "ПО" skip
    v-checkdt1 label "Дата контроля: C"
    v-checkdt2 label "ПО" skip
    v-duedt1 label "Дата Погашения: C"
    v-duedt2 label "ПО" skip
    v-parsts label "По статусу" format "x(9)" skip
    v-cifc label "Код Клиента" format "x(8)" skip
    v-cifn label "Имя Клиента" format "x(32)"
  with centered overlay row 7 side-labels title " ПАРАМЕТРЫ ОТБОРА СПИСКА ДОЛЖНИКОВ ".

DEFINE QUERY q1 for t-debt.

def browse b1
    query q1 no-lock
    display
        t-debt.cif      label "КОД КЛ" format "x(6)"
        t-debt.name     label "ФИО" format "x(37)"
        t-debt.stype    label "ВИД" format "xx"
        t-debt.eday     label "Погаш" format "zzz9"
        t-debt.checkdt  label "Контр" format "99/99/99"
        t-debt.sts      label "СТС" format "xxx"
        t-debt.bal1 + t-debt.bal2 + t-debt.bal3 + t-debt.balcom + t-debt.balz1 + t-debt.balz2 + t-debt.balzpen /*+ t-debt.bal4 + t-debt.bal5*/ label "СуммаДолга" format "->>>,>>>,>>9.99"
        t-debt.days     label "ДНИ" format "zzz9"
        t-debt.days_prc label "ДН%" format "zzz9"
        t-debt.prkol    label "КПр" format "zzz9"
        with 25 down  /* title "СПИСОК ЗАДОЛЖНИКОВ" */ no-labels no-box.

DEFINE BUTTON binfo  LABEL "Изменить".
DEFINE BUTTON bank   LABEL "Анкета".
DEFINE BUTTON bhist  LABEL "История".
DEFINE BUTTON bturn  LABEL "Счет".
DEFINE BUTTON bgraf  LABEL "График".
DEFINE BUTTON bcal   LABEL "Календари".
DEFINE BUTTON bcalp  LABEL "ГрафикОплата".
DEFINE BUTTON bparam LABEL "Параметры".
DEFINE BUTTON bexit  LABEL "Выход".
/*DEFINE BUTTON bsz    LABEL "Служеб.записки".*/
DEFINE BUTTON bmall  LABEL "Отметить все".
DEFINE BUTTON bcrlet LABEL "Создать письма".

def frame f1
    b1 help "<ENTER> - действия <F2> - выбор письма"
    skip(1)
    binfo
    bank
    bhist
    bturn
    bgraf
    bcal
    bcalp skip
    bparam
    bcrlet
    /*bsz*/
    bmall
    bexit
  with size 100 by 32 centered row 3.

def frame f2
  "Посл.письмо:"
  t-debt.lastlt no-label format "x(20)"
  "от"
  t-debt.lastltdt no-label
  "-> выбраны:"
  t-debt.yessendlt format "x(15)" no-label
  with row 35 centered width 80 overlay.

/* в нижней строке выводим детали платежа */
ON VALUE-CHANGED OF b1 in frame f1 DO:
  if num-results("q1") > 0 then
    DISPLAY t-debt.lastlt t-debt.lastltdt t-debt.yessendlt WITH FRAME f2.
  else
    DISPLAY "" @ t-debt.lastlt ? @ t-debt.lastltdt "" @ t-debt.yessendlt WITH FRAME f2.
END.

/* по нажатию ENTER вводим действия */
ON return of b1 in FRAME f1 DO:
  DO i = b1:NUM-SELECTED-ROWS TO 1 by -1 transaction:
    method-return = b1:FETCH-SELECTED-ROW(i).
    GET CURRENT q1 NO-LOCK.
    find current t-debt.
    v-lon = t-debt.lon.
    run pkdebtact (t-debt.lon).
  end.
  /* перерисуем список */
  run reopen (yes).

  /* Спозиционируем курсор */
  find first t-debt where t-debt.lon = v-lon.
  r = rowid (t-debt).
  REPOSITION q1 TO ROWID r.
  browse b1:refresh().
end.


/* по нажатию <F2> вводим действия */
ON HELP of FRAME f1 DO:
  DO i = b1:NUM-SELECTED-ROWS TO 1 by -1 transaction:
    method-return = b1:FETCH-SELECTED-ROW(i).
    GET CURRENT q1 NO-LOCK.
    find current t-debt.
    run pklttype (input-output t-debt.yessendlt).
    find first t-pkdebt where t-pkdebt.lon = t-debt.lon exclusive-lock no-error.
    if avail t-pkdebt then
    t-pkdebt.yessendlt =  t-debt.yessendlt.
    browse b1:refresh().
  end.
   /* перерисуем сведения в нижнем фрейме */
    apply "VALUE-CHANGED" to BROWSE b1.
end.

ON CHOOSE OF bhist IN FRAME f1 do:
  s-pkankln  = t-debt.ln.
  s-credtype = t-debt.credtype.
  run pkhist.
  pause 0.
end.


ON CHOOSE OF bgraf IN FRAME f1 do:
  s-pkankln  = t-debt.ln.
  s-credtype = t-debt.credtype.
  run pkprtgraf.
  /*run pkprtgraf(false).*/
end.

ON CHOOSE OF bcal IN FRAME f1 do:
  s-lon  = t-debt.lon.
  run calxls.
end.

ON CHOOSE OF bcalp IN FRAME f1 do:
  s-lon  = t-debt.lon.
  run calxlsm.
end.

ON CHOOSE OF bank IN FRAME f1 do:
  s-pkankln  = t-debt.ln.
  s-credtype = t-debt.credtype.
  run pkankviw.
end.

ON CHOOSE OF bturn IN FRAME f1 do:
  s-cif  = t-debt.cif.
  run cif-aaa.
    pause 0.
end.


/* Изменить личные сведения */
ON CHOOSE of binfo IN FRAME f1 DO:
  s-cif = t-debt.cif.
  run cif-infe.
    apply "VALUE-CHANGED" to BROWSE b1.
  pause 0.
end.

/* ОТМЕТИТЬ ВСЕ - выбираем виды писем и проставляем их во все записи */
ON CHOOSE of bmall IN FRAME f1 DO:
  v-char = "".
  run pklttype (input-output v-char).

  for each t-debt.
    t-debt.yessendlt = v-char.
  end.
end.


/* Удалить */
ON CHOOSE of bcrlet IN FRAME f1 DO:
  find first t-debt where t-debt.yessendlt <> "" no-lock no-error.
  if not avail t-debt then do:
    message skip " Нет выбранных клиентов для рассылки писем!" skip(1)
            view-as alert-box button ok title " ОШИБКА ! ".
  end.
  else do:
    /* пройти по списку типов писем */
    new_ved = true.
    for each bookcod where bookcod.bookcod = s-bookcod and
             bookcod.code matches s-codemask no-lock:
      find first t-debt where lookup(substr(bookcod.code, 7), t-debt.yessendlt) > 0 no-error.
      if avail t-debt then do:
        /* просмотреть выбранные письма */
        i = 0.
        for each t-debt where lookup(substr(bookcod.code, 7), t-debt.yessendlt) > 0
        break by t-debt.crc DESC by t-debt.bal3 DESC /* by t-debt.balzpen DESC */:
          i = i + 1.
          s-lon = t-debt.lon.
          /* if t-debt.sts <> "Z" then */
               run value("pkletter" + substr(bookcod.code, 7)) (first(t-debt.bal3), last(t-debt.bal3), "", i,
                                                                integer(t-debt.days), t-debt.bal1, t-debt.bal2,
                                                                t-debt.balpen, t-debt.balcom, new_ved, output v-vednom).
          /*
          else run value("pkletter" + substr(bookcod.code, 7)) (first(t-debt.balzpen), last(t-debt.balzpen), "", i,
                                                                integer(t-debt.days), t-debt.balz1, t-debt.balz2,
                                                                t-debt.balzpen, new_ved, output v-vednom).
          */
          new_ved = false.
        end.
        unix silent cptwin value(s-filename + substr(bookcod.code, 7) + ".html") winword.
      end.
    end.

    run pkltlabel (no, string(v-vednom)).

    /* перерисуем список */
     for each t-debt:
          find last letters where letters.bank = s-ourbank and letters.ref = t-debt.lon no-lock use-index refrdt no-error.
          if avail letters then do:
            assign t-debt.lastlt   = letters.docnum
                   t-debt.lastltdt = letters.rdt
                   t-debt.roll     = letters.roll.
          end.
          else
            assign t-debt.lastlt   = ""
                   t-debt.lastltdt = ?
                   t-debt.roll     = 0.
     end.

    v-ans = yes.
    message skip " Сформированы письма по выбранному списку!" skip(1)
                 " Очистить отметки ?"
            view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.

    if v-ans then do:
      for each t-debt:
        t-debt.yessendlt = "".
        find first t-pkdebt where t-pkdebt.lon = t-debt.lon exclusive-lock no-error.
        if avail t-pkdebt then
        t-pkdebt.yessendlt =  "".

      end.
    end.

    /* перерисуем сведения в нижнем фрейме */
    apply "VALUE-CHANGED" to BROWSE b1.
  end.
end.

/* Заново вводим параметры */
ON CHOOSE of bparam IN FRAME f1 DO:
    update v-limit1 v-limit2 v-days1 v-days2 v-checkdt1 v-checkdt2
           v-duedt1 v-duedt2 v-parsts v-cifc v-cifn
           with frame f-param.
    v-parsts = trim(v-parsts).
    v-cifc = trim(v-cifc).
    v-cifn = trim(v-cifn).
    run reopen (no).
end.

/* Выход */
ON CHOOSE of bexit IN FRAME f1 DO:
   apply "enter-menubar" to frame f1.
end.

/*Служебные Записки*/
/*def var v-select as integer no-undo.
def var v-dirname as char no-undo.
def var v-dirname1 as char no-undo.
def var v-date as char no-undo.
def var v-clname as char no-undo.
def var v-proc1 as char no-undo.
def var v-proc2  as char no-undo.
def var v-cradtype  as char no-undo.
def var v-crc  as char no-undo.
def var v-sum as deci no-undo.
def var v-rate as deci no-undo.
def var v-strdt as char no-undo.
def var v-expdt as char no-undo.
def var v-plod as deci no-undo.
def var v-plprc as deci no-undo.
def var v-plcom as deci no-undo.
def var v-daypros as char no-undo.
def var v-sumod as deci no-undo.
def var v-prosprc as deci no-undo.
def var v-prosod as deci no-undo.
def var v-totsum as deci no-undo.
def var v-prc as deci no-undo.
def var v-nbalprc as deci no-undo.
def var v-comdolg as deci no-undo.
def var v-pen as deci no-undo.
def var v-balpen as deci no-undo.
def var v-nbalpen as deci no-undo.
def var v-jbname as char no-undo.
def var v-trade as char no-undo.
def var v-family as char no-undo.
def var v-mprof as deci no-undo.
def var v-othprofit as char no-undo.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
def var v-ourbank as char no-undo.
def var v-dog as char no-undo.
def var v-clcode as char no-undo.
def var v-str as char no-undo.
def var v-penoplat as deci no-undo.
def var v-pendel as deci no-undo.
def var v-ofc as char no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def buffer b-jl for jl.
def stream v-out.
v-ourbank = comm-txb().
ON CHOOSE of bsz in frame f1 do:
  v-select = 0.
  run sel2 (" СЛУЖЕБНЫЕ ЗАПИСКИ ", " 1. СЗ на рефинансирование| 2. СЗ на ресруктуризацию| 3. СЗ на списание неустойки| ВЫХОД ", output v-select).
  if v-select = 0 then return.
  if v-select = 1 then v-infile = "/data/docs/pksz.htm".
  if v-select = 2 or v-select = 3 then v-infile = "/data/docs/pksz1.htm".
  v-ofile = "pksz.htm".

  find first lon where lon.lon = t-debt.lon no-lock no-error.
  if not avail lon then do:
     message "Не найден кредит " + t-debt.lon  view-as alert-box.
     return.
  end.
  find first t-pkdebt where t-pkdebt.lon = t-debt.lon no-lock no-error.
  if lon.grp <> 90 and lon.grp <> 92 then do:
     message "СЗ формируется только по потребительским кредитам" view-as alert-box.
     return.
  end.

  find first pkanketa where pkanketa.bank = v-ourbank and pkanketa.credtype = t-debt.credtype and pkanketa.lon = t-debt.lon no-lock no-error.
  if not avail pkanketa then do:
     message "Не найдена анкета для кредита " + t-debt.lon  view-as alert-box.
     return.
  end.


  v-dirname = ''.
  v-dirname1 = ''.
  if v-ourbank = 'txb00' or v-ourbank = 'txb16' then do:
    v-dirname = 'И.О. Директора ДМ и ВК Жакупбековой С.Б.'.
    v-dirname1 = v-dirname.
  end.
  else do:
    find first txb where txb.consolid and txb.bank = v-ourbank no-lock no-error.
    v-dirname = entry(2,get-sysc-cha ("dkface")) + ' ' + entry(1,get-sysc-cha ("dkface")).
    v-dirname1 = 'Директор (И.О. Диретора) филиала в ' + txb.info + ' ' + get-sysc-cha ("DKPODP").
  end.
  v-date = replace(string(g-today,'99/99/9999'),'/','.') + 'г.'.

  v-proc1 = ''.
  v-proc2 = ''.
  if v-select = 2 then do:
    v-proc1 = 'реструктуризация'.
    v-proc2 = 'реструктуризации'.
  end.
  if v-select = 3 then do:
    v-proc1 = 'списание неустойки'.
    v-proc2 = 'списания неустойки'.
  end.

  v-clname = ''.
  v-clcode = ''.
  v-clname = t-pkdebt.name.
  v-clcode = '(' + lon.cif + ')'.

  v-dog = ''.
  find first loncon where loncon.lon = lon.lon no-lock no-error.
  if avail loncon then v-dog = loncon.lcnt + ' ' + replace(string(pkanketa.docdt,'99/99/9999'),'/','.').

  v-credtype = ''.
  v-credtype = 'Потребительский кредит'.

  v-crc = ''.
  find first crc where crc.crc = lon.crc no-lock no-error.
  if avail crc then v-crc = crc.code.

  v-sum = 0.
  v-sum = pkanketa.summa.

  v-rate = 0.
  v-rate = pkanketa.rateq.

  v-strdt = ''.
  v-expdt = ''.
  v-strdt = string(lon.rdt,'99/99/9999') + 'г.'.
  v-expdt = string(lon.duedt,'99/99/9999') + 'г.'.

  v-plod = 0.
  find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.flp = 0 and lnsch.stdat >= g-today no-lock no-error.
  if avail lnsch then v-plod = lnsch.stval.

  v-plprc = 0.
  v-plprc = round(lon.opnamt * pkanketa.rateq / 1200,2).

  find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
  if avail tarifex2 then v-plcom = tarifex2.ost. else v-plcom = 0.

  run lonbalcrc('lon', lon.lon, g-today, "1,7", yes, lon.crc, output v-sumod).
  run lonbalcrc('lon', lon.lon, g-today, "7", yes, lon.crc, output v-prosod).
  run lonbalcrc('lon', lon.lon, g-today, "9", yes, lon.crc, output v-prosprc).
  run lonbalcrc('lon', lon.lon, g-today, "2", yes, lon.crc, output v-prc).
  run lonbalcrc('lon', lon.lon, g-today, "4", yes, lon.crc, output v-nbalprc).

  v-comdolg = 0.
  for each bxcif where bxcif.cif = lon.cif and bxcif.crc = lon.crc no-lock:
     v-comdolg = v-comdolg + bxcif.amount.
  end.

  v-totsum = 0.
  v-totsum = v-sumod + v-prosprc + v-prc + v-nbalprc + v-comdolg.
  run lonbalcrc('lon', lon.lon, g-today, "5,16", yes, 1, output v-pen).
  run lonbalcrc('lon', lon.lon, g-today, "16", yes, 1, output v-balpen).
  run lonbalcrc('lon', lon.lon, g-today, "5", yes, 1, output v-nbalpen).

  v-jbname = ''.
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error.
  if avail pkanketh then v-jbname = pkanketh.value1.

  v-trade = ''.
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobsn" no-lock no-error.
  if avail pkanketh then v-trade = pkanketh.value1.

  v-family = ''.
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "family" no-lock no-error.
  if avail pkanketh then do:
    case pkanketh.value1:
        when '00' then v-family = "холостяк/не замужем".
        when '01' then v-family = "женат/замужем".
        when '02' then v-family = "в разводе".
        when '03' then v-family = "вдова/вдовец".
    end.
  end.
  if v-family <> "холостяк/не замужем" then do:
      find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "lnames" no-lock no-error.
      if avail pkanketh and trim(pkanketh.value1) <> '' then v-family = v-family + ', ' + pkanketh.value1.
      find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fnames" no-lock no-error.
      if avail pkanketh then v-family = v-family + ' ' + pkanketh.value1.
      find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "mnames" no-lock no-error.
      if avail pkanketh then v-family = v-family + ' ' + pkanketh.value1.
      find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
         pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "child" no-lock no-error.
      if avail pkanketh and trim(pkanketh.value1) <> '' then do:
         v-family = v-family + ', ' + pkanketh.value1.
         if pkanketh.value1 = '1' then v-family = v-family + ' ребенок'.
         if int(pkanketh.value1) > 1 then v-family = v-family + ' детей'.
      end.
  end.

  v-mprof = 0.
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobpr" no-lock no-error.
  if avail pkanketh then v-mprof = deci(pkanketh.value1).

  v-othprofit = ''.
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobpr2s" no-lock no-error.
  if avail pkanketh then do:
     find first  bookcod where bookcod.bookcod = 'pkankdoh' and bookcod.code = pkanketh.value1 no-lock no-error.
     if avail bookcod then v-othprofit = bookcod.name.
  end.

  /* штрафы, оплаченные в тек. году */
  v-penoplat = 0.
  v-pendel = 0.
  for each lonres where lonres.lon = lon.lon and lonres.jdt <= g-today and lonres.lev = 16 no-lock:
    if lonres.dc = 'c' then do:
       find first jl where jl.jh = lonres.jh and jl.dc = 'D' no-lock no-error.
       if avail jl then do:
          if jl.acc = lon.aaa then v-penoplat = v-penoplat + jl.dam.
          if jl.gl = 490000 then v-pendel = v-pendel + jl.dam.
       end.
    end.
  end.
  for each lonres where lonres.lon = lon.lon and lonres.jdt <= g-today and lonres.lev = 5 no-lock:
     if lonres.dc = 'c' then do:
        find first jl where jl.jh = lonres.jh and jl.dc = 'D' no-lock no-error.
        if avail jl then do:
           if (jl.gl = 788000) or (jl.gl = 818000) then do:
              find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
              if avail b-jl and b-jl.gl = 718000 then v-pendel = v-pendel + jl.dam.
           end.
        end.
     end.
  end.
  v-daypros = ''.
  /*здесь должны быть фактические дни просрочки*/
  run lndaysprf(lon.lon,g-today, no, output v-days_od, output v-days_prc).

  v-daypros = string(v-days_od).
  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if avail ofc then v-ofc = ofc.name.
  output stream v-out to value(v-ofile).
  /********/

  input from value(v-infile).
  repeat:
      import unformatted v-str.
      v-str = trim(v-str).

      repeat:
          if v-str matches "*\{\&v-dirname\}*" then do:
              v-str = replace (v-str, "\{\&v-dirname\}", v-dirname).
              next.
          end.

          if v-str matches "*\{\&v-dirname1\}*" then do:
              v-str = replace (v-str, "\{\&v-dirname1\}", v-dirname1).
              next.
          end.
          if v-str matches "*\{\&v-date\}*" then do:
              v-str = replace (v-str, "\{\&v-date\}", v-date).
              next.
          end.

          if v-str matches "*\{\&v-dog\}*" then do:
              v-str = replace (v-str, "\{\&v-dog\}", v-dog).
              next.
          end.

          if v-str matches "*\{\&v-proc1\}*" then do:
              v-str = replace (v-str, "\{\&v-proc1\}", v-proc1).
              next.
          end.

          if v-str matches "*\{\&v-proc2\}*" then do:
              v-str = replace (v-str, "\{\&v-proc2\}", v-proc2).
              next.
          end.

          if v-str matches "*\{\&v-clname\}*" then do:
              v-str = replace (v-str, "\{\&v-clname\}", v-clname).
              next.
          end.

          if v-str matches "*\{\&v-clcode\}*" then do:
              v-str = replace (v-str, "\{\&v-clcode\}", v-clcode).
              next.
          end.

          if v-str matches "*\{\&v-credtype\}*" then do:
              v-str = replace (v-str, "\{\&v-credtype\}", v-credtype).
              next.
          end.

          if v-str matches "*\{\&v-crc\}*" then do:
              v-str = replace (v-str, "\{\&v-crc\}", v-crc).
              next.
          end.

          if v-str matches "*\{\&v-sum\}*" then do:
              v-str = replace (v-str, "\{\&v-sum\}", trim(string(v-sum,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-rate\}*" then do:
              v-str = replace (v-str, "\{\&v-rate\}", trim(string(v-rate,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-strdt\}*" then do:
              v-str = replace (v-str, "\{\&v-strdt\}", v-strdt).
              next.
          end.

          if v-str matches "*\{\&v-expdt\}*" then do:
              v-str = replace (v-str, "\{\&v-expdt\}", v-expdt).
              next.
          end.

          if v-str matches "*\{\&v-plod\}*" then do:
              v-str = replace (v-str, "\{\&v-plod\}", trim(string(v-plod,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-plprc\}*" then do:
              v-str = replace (v-str, "\{\&v-plprc\}", trim(string(v-plprc,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-plcom\}*" then do:
              v-str = replace (v-str, "\{\&v-plcom\}", trim(string(v-plcom,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-plsum\}*" then do:
              v-str = replace (v-str, "\{\&v-plsum\}", trim(string(v-plcom + v-plprc + v-plod,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-sumod\}*" then do:
              v-str = replace (v-str, "\{\&v-sumod\}", trim(string(v-sumod,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-prosod\}*" then do:
              v-str = replace (v-str, "\{\&v-prosod\}", trim(string(v-prosod,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-daypros\}*" then do:
              v-str = replace (v-str, "\{\&v-daypros\}", v-daypros).
              next.
          end.

          if v-str matches "*\{\&v-prosprc\}*" then do:
              v-str = replace (v-str, "\{\&v-prosprc\}", trim(string(v-prosprc,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-prc\}*" then do:
              v-str = replace (v-str, "\{\&v-prc\}", trim(string(v-prc,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-nbalprc\}*" then do:
              v-str = replace (v-str, "\{\&v-nbalprc\}", trim(string(v-nbalprc,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-comdolg\}*" then do:
              v-str = replace (v-str, "\{\&v-comdolg\}", trim(string(v-comdolg,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-totsum\}*" then do:
              v-str = replace (v-str, "\{\&v-totsum\}", trim(string(v-totsum,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-pen\}*" then do:
              v-str = replace (v-str, "\{\&v-pen\}", trim(string(v-pen,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-balpen\}*" then do:
              v-str = replace (v-str, "\{\&v-balpen\}", trim(string(v-balpen,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-nbalpen\}*" then do:
              v-str = replace (v-str, "\{\&v-nbalpen\}", trim(string(v-nbalpen,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-jbname\}*" then do:
              v-str = replace (v-str, "\{\&v-jbname\}", v-jbname).
              next.
          end.

          if v-str matches "*\{\&v-trade\}*" then do:
              v-str = replace (v-str, "\{\&v-trade\}", v-trade).
              next.
          end.

          if v-str matches "*\{\&v-family\}*" then do:
              v-str = replace (v-str, "\{\&v-family\}", v-family).
              next.
          end.

          if v-str matches "*\{\&v-mprof\}*" then do:
              v-str = replace (v-str, "\{\&v-mprof\}", trim(string(v-mprof,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-othprofit\}*" then do:
              v-str = replace (v-str, "\{\&v-othprofit\}", v-othprofit).
              next.
          end.

          if v-str matches "*\{\&v-penoplat\}*" then do:
              v-str = replace (v-str, "\{\&v-penoplat\}", trim(string(v-penoplat,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-pendel\}*" then do:
              v-str = replace (v-str, "\{\&v-pendel\}", trim(string(v-pendel,'>>>>>>>>>>>>>9.99'))).
              next.
          end.

          if v-str matches "*\{\&v-ofc\}*" then do:
              v-str = replace (v-str, "\{\&v-ofc\}", v-ofc).
              next.
          end.
          leave.
      end. /* repeat */

      put stream v-out unformatted v-str skip.
  end. /* repeat */
  input close.
    /********/

  output stream v-out close.
  output stream v-out to value(v-ofile) append.
  output stream v-out close.
  unix silent value("cptwin " + v-ofile + " winword").
  unix silent value("rm -r " + v-ofile).

end.*/
/* первичное открытие списка */
run reopen (no).

ENABLE all WITH centered FRAME f1.
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR "enter-menubar" of frame f1.

close query q1.
hide all no-pause.

/* переформирование списка отмеченных писем из списка задолжников */
procedure dolst.
  for each t-debt. delete t-debt. end.
       for each t-pkdebt:
         if t-pkdebt.days > v-days2 or t-pkdebt.days < v-days1 then next.

         v-sumd = t-pkdebt.bal1 + t-pkdebt.bal2 + t-pkdebt.bal3 + t-pkdebt.balcom + t-pkdebt.balz1 + t-pkdebt.balz2
                + t-pkdebt.balzpen + t-pkdebt.bal4 + t-pkdebt.bal5.
         if (v-sumd < v-limit1 or v-sumd > v-limit2) and (t-pkdebt.sts <> "Z") then next.

         if length(string(v-checkdt1)) > 0 and length(string(v-checkdt2)) > 0 then do:
             if t-pkdebt.checkdt > v-checkdt2
                or t-pkdebt.checkdt < v-checkdt1
                or t-pkdebt.checkdt = ? then next.
         end.

         if (v-duedt1 >= 0 and v-duedt2 > 0) then do:
            if t-pkdebt.eday > v-duedt2
                or t-pkdebt.eday < v-duedt1 then next.
         end.

         if v-parsts <> "" and t-pkdebt.sts <> v-parsts then next.

         if v-cifc <> "" and t-pkdebt.cif  <> v-cifc then next.

         if v-cifn <> "" and not (t-pkdebt.name matches ("*" + v-cifn + "*")) then next.

         create t-debt.
         buffer-copy t-pkdebt to t-debt.
         find first londebt where londebt.lon = t-pkdebt.lon no-lock no-error.
         if avail londebt then /*t-debt.days_prc = londebt.days_prc.*/
         run lndaysprf(londebt.lon,g-today, no, output v-days_od, output t-debt.days_prc).
       end.
end procedure.

/* переоткрыть browse */
procedure reopen.
  def input parameter p-close as logical.
  if p-close then close query q1.
  run dolst.
  open query q1 for each t-debt by eday.
  if p-close then apply "VALUE-CHANGED" to BROWSE b1.
end.
