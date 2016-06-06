/* MCLN_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Мониторинг движений по счетам клиентов
        посылается файл изменений по почте
 * RUN
        процесс платежной системы
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-1
 * AUTHOR
        16.04.2004 nadejda
 * CHANGES
        08.05.2004 nadejda - добавлен мониторинг платежей для клиентов, получивших кредит
        14.05.2004 nadejda - для мониторинга ссуд изменен принцип - посылается общий список после 16.00
        03.08.2004 tsoy    - Формировать отчет только для записей где coll.whn = g-today
*/


{global.i}

def temp-table t-acc
  field aaa as char
  field cif as char
  field cno as integer
  index main is primary cif aaa.

def temp-table t-jl
  field cif as char
  field aaa as char
  field jh as integer
  field ln as integer
  field jdt as date
  field whn as date
  field tim as integer
  field dc as char
  field sum as decimal
  field crc as integer
  field lev as integer
  field gl as integer
  field ref as char
  field who as char
  field rem as char
  field cno as integer
  field jlnew as logical
  field type as integer
  index main is primary type crc cif aaa jh ln
  index type2 cif cno
  index jlnew jlnew.

def var i as integer.
def var v-tim as integer.
def var v-timb as integer.
def var v-adr as char.
def var v-clns as char.
def var v-yes as logical.
def var v-cashgl like gl.gl init 100100.
def var v-jlnew as logical.
def var v-mondat as date.  /* текущая дата мониторинга */
def var v-type as integer.

def var v-params as char extent 2 init
  ["moncln,monadr,особых клиентов", "monlon,monlop,юридических лиц - заемщиков"].

def buffer b-jl for jl.


find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if avail sysc then v-cashgl = sysc.inval.

v-mondat = today /* g-today / * отладочное */.

/* мониторинг платежей особых клиентов (подозрительных), список дает руководство */
run monitor (1).

/* мониторинг платежей клиентов-юрлиц, получивших кредит */
run monitor (2).


procedure monitor.
  def input parameter p-type as integer.
  def var v-list as char.
  def var v-recev as char.
  def var v-header as char.

  v-list = entry(1, v-params[p-type]).
  v-recev = entry(2, v-params[p-type]).
  v-header = entry(3, v-params[p-type]).

  find sysc where sysc = v-list no-lock no-error.
  if not avail sysc then return.

  /* проверить, есть ли клиенты для мониторинга */
  case p-type :
    when 1 then do: 
      if sysc.chval = "" then return. 
    end.
    when 2 then do:
      find first coll where coll.type = "1" and coll.sts < "9" and coll.whn = g-today no-lock no-error.
      if not avail coll then return.
    end.
  end.


  /* список адресов получателей сообщений */
  find sysc where sysc = v-recev no-lock no-error.
  v-adr = trim(sysc.chval).
  /*v-adr = "nadezhda". / * отладочное */
  repeat:
    if index(v-adr, ",,") = 0 then leave.
    v-adr = replace(v-adr, ",,", ",").
  end.
  if substr(v-adr, length(v-adr)) = "," then v-adr = substr(v-adr, 1, length(v-adr) - 1).
  if substr(v-adr, 1) = "," then v-adr = substr(v-adr, 2).
  if v-adr = "" then do:
    run mail("support@elexnet.kz", "TEXAKABANK <abpk@elexnet.kz>", "Движения по счетам " + v-header + " - ошибка!", "Мониторинг движений по счетам " + v-header + ". Не настроен список адресов для отправки сообщений (в списке системных настроек параметр " + caps(v-recev) + ") !!!" , "1", "", "").
    return.
  end.
  v-adr = replace(v-adr, ",", "@elexnet.kz,").
  v-adr = v-adr + "@elexnet.kz".



  find sysc where sysc = v-list no-lock no-error.
  if sysc.daval = ? or sysc.daval < v-mondat then do transaction:
    if sysc.daval = ? then 
      run mail(v-adr, "TEXAKABANK <abpk@elexnet.kz>", "Движения по счетам " + v-header + " - тест", "Мониторинг движений по счетам " + v-header + ". ТЕСТОВОЕ СООБЩЕНИЕ!!!" , "1", "", "").

    find current sysc exclusive-lock.
    sysc.daval = v-mondat.
    sysc.inval = 0.
    find current sysc no-lock.
  end.

  v-timb = sysc.inval.
  /*if p-type = 2 then v-timb = 43200. / * отладочное */
  v-tim = time.
  if v-timb >= v-tim then return.

  do transaction:
    find sysc where sysc = v-list exclusive-lock no-error.
    sysc.inval = v-tim.
    find current sysc no-lock.
  end.

  /* собрать список счетов для мониторинга */
  for each t-acc. delete t-acc. end.
  for each t-jl. delete t-jl. end.

  case p-type :
    when 1 then do:
      find sysc where sysc = v-list no-lock no-error.
      v-clns = sysc.chval.
      /*v-clns = "T33062". / * отладочное */

      do i = 1 to num-entries (v-clns):
        for each aaa where aaa.cif = entry(i, v-clns) and aaa.sta <> "c" no-lock:
          create t-acc.
          assign t-acc.cif = entry(i, v-clns)
                 t-acc.aaa = aaa.aaa.
        end.
      end.
    end.

    when 2 then do:
      /* письма шлем только после 16 часов */
      find sysc where sysc = v-recev no-lock no-error.
      if v-tim < sysc.inval /* 36000 / * отладочное */ then return.

      if sysc.daval = ? or sysc.daval < v-mondat then do:
        v-timb = 0.
        find current sysc exclusive-lock.
        sysc.daval = v-mondat.
        find current sysc no-lock.
      end.
  
      for each coll where coll.type = "1" and coll.sts < "9" and coll.whn = g-today no-lock:
        for each aaa where aaa.cif = coll.cif and aaa.sta <> "c" no-lock:
          /* мониторим только текущие счета */
          find lgr where lgr.lgr = aaa.lgr no-lock no-error.
          if lgr.led <> "DDA" then next.

          create t-acc.
          assign t-acc.cif = coll.cif
                 t-acc.cno = coll.cno
                 t-acc.aaa = aaa.aaa.
        end.
      end.
    end.
  end case.


  for each t-acc:
    for each jl where jl.jdt = g-today and jl.acc = t-acc.aaa no-lock:
      if jl.who = "bankadm" then next. /* исключить проводки закрытия дня */
      if jl.lev <> 1 then next.  /* только движения по основной сумме */

      find jh where jh.jh = jl.jh no-lock no-error.
      /* проводки, сделанные более ранним календарным днем или после начала просмотра - не берем */
      if (jh.whn <> v-mondat or (jh.whn = v-mondat and jh.tim > v-tim)) then next.

      v-jlnew = (jh.tim >= v-timb and jh.tim <= v-tim).
      v-type = 0.

      case p-type :
        when 1 then do:
          v-yes = v-jlnew.  /* по особым клиентам берем все новые движения по всем счетам */
        end.
        when 2 then do:
          /* для казначейства кредитовые проводки не мониторим */
          if jl.dc = "c" then next.   
          
          v-yes = no.

          /* мониторим не все дебетовые движения, а только на кассу, внешние и на конвертацию */
          /* поискать внешний платеж */
          if jh.party <> "" then do:
            find remtrz where remtrz.remtrz = substr(jh.party, 1, 10) no-lock no-error.
            if avail remtrz and 
               remtrz.ptype <> "M" and 
               remtrz.jh1 = jh.jh and 
               remtrz.tcrc = jl.crc and 
               remtrz.amt = jl.dam then do: v-yes = yes. v-type = 1. end.
          end.

          /* поискать конвертацию */
          if not v-yes then do:
            find first dealing_doc where dealing_doc.jh = jl.jh no-lock no-error.
            if avail dealing_doc then do:
              for each b-jl where b-jl.jh = jl.jh no-lock:
                if b-jl.dc = "d" or b-jl.cam <> jl.dam then next.

                if b-jl.sub = "arp" then do:
                  /* перевод на транзитный счет клиентских конвертаций */
                  v-yes = yes.
                  v-type = 2.
                  leave.
                end.
              end.
            end.
          end.

          /* поискать кассу */
          if not v-yes then do:
            for each b-jl where b-jl.jh = jl.jh no-lock:
              if b-jl.dc = "d" then next.

              if b-jl.gl = v-cashgl and b-jl.cam = jl.dam then do:
                /* перевод в кассу */
                v-yes = yes.
                v-type = 1.
                leave.
              end.
            end.
          end.

        end.
      end case.
      if not v-yes then next.

      create t-jl.
      assign t-jl.cif = t-acc.cif
             t-jl.aaa = t-acc.aaa
             t-jl.jh = jh.jh
             t-jl.ln = jl.ln
             t-jl.jdt = jl.jdt
             t-jl.whn = jl.whn
             t-jl.tim = jh.tim
             t-jl.dc = jl.dc
             t-jl.sum = if jl.dc = "d" then jl.dam else jl.cam
             t-jl.crc = jl.crc
             t-jl.lev = jl.lev
             t-jl.gl = jl.gl
             t-jl.ref = jh.party
             t-jl.who = jl.who
             t-jl.cno = t-acc.cno
             t-jl.jlnew = v-jlnew
             t-jl.type = v-type.
      
      do i = 1 to 4:
        if trim(jl.rem[i]) <> "" then do:
          if t-jl.rem <> "" then t-jl.rem = t-jl.rem + "<br>".
          t-jl.rem = t-jl.rem + "&nbsp;" + trim(jl.rem[i]).
        end.
      end.
    end.
  end.

  find first t-jl where t-jl.jlnew no-error.
  if not avail t-jl then return.

  unix silent("rm -f rptmon.ht*").

  output to "rptmon.html".
  {html-title.i &title = "Мониторинг движений по счетам клиентов" &size-add = "x-"}

  put unformatted 
    "<P align=left><FONT size=3 face='Arial cyr, sans'><b>Мониторинг движений по счетам " + v-header + "<br><br>" skip 
    string(v-mondat, "99/99/9999") "<br>изменения за период времени с " string(v-timb, "HH:MM:SS") " по " string(v-tim, "HH:MM:SS") "</b></FONT></P>"skip
    "<table width=100% border=1 cellspacing=1>"
      "<tr valign=bottom style=""fon-size:xx-small""><th>Код клиента</th>"
      "<th>Счет</th>" 
      "<th>Наименование&nbsp;клиента</th>"
      "<th>Проводка</th>" 
      "<th>Дата опердня</th>" 
      "<th>Дата календ.</th>" 
      "<th>Время</th>" 
      "<th>Деб/Кред</th>" 
      "<th>Сумма</th>" 
      "<th>Валюта</th>" 
      "<th>Уровень</th>" 
      "<th>Исполнитель</th>" 
      "<th>Референс</th>" 
      "<th>Детали платежа</th>" 
      "</tr>" skip.

  for each t-jl break by t-jl.type by t-jl.crc by t-jl.cif:
      if first-of (t-jl.type) and t-jl.type > 0 then do:
        put unformatted 
          "<tr><td colspan=13>&nbsp;</td></tr>" skip
          "<tr><td colspan=13 align=left><B>" if t-jl.type = 1 then "ДЕБЕТОВЫЕ ОПЕРАЦИИ" else "КОНВЕРСИИ" "</B></td></tr>" skip.
      end.

      put unformatted "<tr valign=top>"
        "<td align=center>" t-jl.cif "</td>" skip
        "<td align=center>" t-jl.aaa "</td>" skip.

      find cif where cif.cif = t-jl.cif no-lock no-error.
      put unformatted
        "<td align=left><b>" trim(trim(cif.prefix) + " " + trim(cif.name)) "</b></td>" skip
        "<td align=center>" t-jl.jh "</td>" skip
        "<td align=center>" t-jl.jdt "</td>" skip
        "<td align=center>" t-jl.whn "</td>" skip
        "<td align=center>" string(t-jl.tim, "HH:MM:SS") "</td>" skip
        "<td align=center>" t-jl.dc "</td>" skip
        "<td align=right>" string(t-jl.sum, ">>>,>>>,>>>,>>>,>>>,>>9.99") "</td>" skip.

      find crc where crc.crc = t-jl.crc no-lock no-error.
      put unformatted
        "<td align=center>" crc.code "</td>" skip.

      find gl where gl.gl = t-jl.gl no-lock no-error.
      put unformatted
        "<td align=center>" t-jl.lev "<NOBR>(" + gl.sname + ")</NOBR></td>" skip
        "<td align=center>" t-jl.who "</td>" skip
        "<td align=center>" t-jl.ref "</td>" skip
        "<td align=left style=""font-size:xx-small"">" t-jl.rem "</td>" skip
      "</tr>"skip.


      accumulate t-jl.sum (sub-total by t-jl.crc by t-jl.cif).

      if last-of (t-jl.cif) then do:
        put unformatted "<tr valign=top style=""font:bold"">"
          "<td>&nbsp;</td>" skip
          "<td colspan=4 align=left>Итого по клиенту " t-jl.cif " " caps(trim(trim(cif.prefix) + " " + trim(cif.name))) "</td>" skip
          "<td colspan=4 align=right>" string(accum sub-total by t-jl.cif t-jl.sum, ">>>,>>>,>>>,>>>,>>>,>>9.99") "</td>" skip
          "<td align=center>" crc.code "</td>" skip
          "<td colspan=4>&nbsp;</td></tr>" skip.
      end.

      if last-of (t-jl.crc) then do:
        put unformatted "<tr valign=top style=""font:bold"">"
          "<td>&nbsp;</td>" skip
          "<td colspan=4 align=left>ИТОГО по валюте " crc.code "</td>" skip
          "<td colspan=4 align=right>" string(accum sub-total by t-jl.crc t-jl.sum, ">>>,>>>,>>>,>>>,>>>,>>9.99") "</td>" skip
          "<td align=center>" crc.code "</td>" skip
          "<td colspan=4>&nbsp;</td></tr>" skip.
      end.
  end.

  {html-end.i " "}
  output close.

  unix silent value("rcode rptmon.html " + " rptmon.htm " + " -kw > /dev/null").
  run mail(v-adr, "TEXAKABANK <abpk@elexnet.kz>", "Движения по счетам " + v-header, "Мониторинг движений по счетам " + v-header + ". См. вложение." , "1", "", "rptmon.htm").

  /*unix silent cptwin rptmon.html excel.  / * отладочное */
  
  unix silent("rm -f rptmon.ht*").

  /* для мониторинга казначейства записать данные о последнем посланном сообщении */
  if p-type = 2 then do:
    for each t-jl break by t-jl.cif by t-jl.cno:
      if first-of (t-jl.cno) then do:
        find coll where coll.cif = t-jl.cif and coll.cno = t-jl.cno exclusive-lock no-error.
        assign coll.mailadr = v-adr
               coll.mailwhn = v-mondat
               coll.mailtim = v-tim.
        release coll.
      end.
    end.
  end.

end procedure.

