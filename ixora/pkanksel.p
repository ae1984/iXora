/* pkanksel.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
        Печать анкет по некоторому отбору
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-4-1
 * AUTHOR
        24.01.2003 nadejda
 * CHANGES
        09.12.2003 nadejda - изменен формат временной таблицы
        23/05/2005 madiyar - добавил выборку по интернет-анкетам
        05/07/2005 madiyar - добавил выборку по письмам
        22/05/2006 madiyar - добавил выборку по рефинансированным кредитам
*/

{global.i}

{pk.i "new"}

/**
s-credtype = "6".
**/

{pkvalidkrit.i}

def var v-uslotkaz  as integer format "9" init 1.
def var v-pkankln as integer format ">>>>>>>>9" init 0.
def var v-pkankrnn as char format "x(12)" init "".
def var v-ankyes as logical.
def var v-orgs   as char format "x(20)".
def var v-pos    as char format "x(20)".
def var v-stag   as char format "x(20)".
def var v-income as char format "x(20)".
def var v-fam    as char format "x(20)".
def var v-child  as integer format ">9".
def var v-house  as logical format "да/нет".
def var v-auto   as logical format "да/нет".
def var v-finob  as logical format "да/нет".
def var v-acc    as integer format ">9".
def var v-diapb  as integer format ">>>>>>>>>9".
def var v-diape  as integer format ">>>>>>>>>9".
def var v-periodb as date format "99/99/9999".
def var v-periode as date format "99/99/9999".
def var v-rateb  as integer format ">>>>>>>>>9".
def var v-ratee  as integer format ">>>>>>>>>9".
def var v-card   as logical format "да/нет".
def var v-letter   as logical format "да/нет".
def var v-uslref  as logical format "да/нет".
def var v-uslinet  as logical format "да/нет".
def var v-usltoday  as logical format "да/нет".
def var v-uslhouse  as logical format "да/нет".
def var v-uslorgs  as logical format "да/нет".
def var v-uslpos  as logical format "да/нет".
def var v-uslstag  as logical format "да/нет".
def var v-uslincome  as logical format "да/нет".
def var v-uslfam  as logical format "да/нет".
def var v-uslchild  as logical format "да/нет".
def var v-uslauto  as logical format "да/нет".
def var v-uslfinob  as logical format "да/нет".
def var v-uslacc  as logical format "да/нет".
def var v-uslcard  as logical format "да/нет".
def var v-uslletter  as logical format "да/нет".
def var v-usldiap as logical format "да/нет".
def var v-uslperiod as logical format "да/нет".
def var v-uslrate as logical format "да/нет".
def var v-msgerr as char.
def var v-sprav  as char.
def var v-value1 as char.
def var v-stsname as char.
def var v-logyes as char init "yes,y,true,t,да,д,0".
def var v-logno  as char init "no,n,false,f,нет,н,1".
def var v-refusname as char format "x(40)".
def var v-i as integer.


def new shared temp-table t-anks
  field ln like pkanketa.ln
  field rnn like pkanketa.rnn
  field rating like pkanketa.rating
  index ln is primary unique ln
  index rnn rnn.


function validusl returns logical (p-sprav as char, p-value as char, output p-msg as char).
  def var l as logical.
  def var i as integer.

  if p-value = "" then 
    return true.
  
  find bookref where bookref.bookcod = p-sprav no-lock no-error.
  if avail bookref then do:
    l = true.
    do i = 1 to num-entries(p-value):
      run valid-book (p-sprav, entry(i, p-value), output l).
      if not l then leave.
    end.
    if not l then p-msg = " Такой код в справочнике не найден !".
    return l.
  end.
end.

form 
  v-pkankln label "Одна анкета по номеру" 
    validate (v-pkankln = 0 or can-find(pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = v-pkankln no-lock), " Нет такого номера !")
    help " Номер анкеты или 0 (F2 - поиск анкеты)" " "
  v-pkankrnn label "По одному человеку (РНН)" validate (v-pkankrnn = "" or valid-krit("rnn", v-pkankrnn, s-credtype, output v-msgerr), v-msgerr)
    help " РНН для идентификации клиента (F2 - поиск человека)" skip

  v-usltoday label "          За сегодняшний день" help " Отбирать/нет по данному параметру" skip(1)
  v-uslref label "      Анкеты-рефинансирование" help " Отбирать/нет по данному параметру" skip
  v-uslinet label "              Интернет-анкеты" help " Отбирать/нет по данному параметру" skip
  v-uslotkaz label " 1) все 2) успешные 3) отказы" validate (v-uslotkaz >= 1 and v-uslotkaz <= 3, " Неверные данные !") 
    help " Диапазон отбора анкет - все/выданные кредиты/отказы в кредите" " " skip

  v-usldiap   label " Диапазон номеров анкет" help " Отбирать/нет по данному параметру"
  v-diapb label "" help " Задайте первое значение диапазона"
  v-diape label "" help " Задайте последнее значение диапазона" " " skip

  v-uslperiod label "           Диапазон дат" help " Отбирать/нет по данному параметру"
  v-periodb label "" help " Задайте начальную дату"
  v-periode label "" help " Задайте конечную дату" " " skip

  v-uslrate  label "      Диапазон рейтинга" help " Отбирать/нет по данному параметру"
  v-rateb label "" help " Задайте последнее значение диапазона"
  v-ratee label "" help " Задайте первое значение диапазона" " " skip

  v-uslorgs label "        По месту работы" help " Отбирать/нет по данному параметру"
  v-orgs label "" help " F2 - справочник" validate(validusl("pkankorg", v-orgs, output v-msgerr), v-msgerr) " " skip

  v-uslpos label "           По должности" help " Отбирать/нет по данному параметру"
  v-pos label "" help " F2 - справочник" validate(validusl("pkankkat", v-pos, output v-msgerr), v-msgerr) " " skip

  v-uslstag label "        По стажу работы" help " Отбирать/нет по данному параметру"
  v-stag label "" help " F2 - справочник" validate(validusl("pkankwrk", v-stag, output v-msgerr), v-msgerr) " " skip

  v-uslincome label "              По доходу" help " Отбирать/нет по данному параметру"
  v-income label "" help " F2 - справочник" validate(validusl("pkankrev", v-income, output v-msgerr), v-msgerr) " " skip

  v-uslfam label " По семейному положению" help " Отбирать/нет по данному параметру"
  v-fam label "" help " F2 - справочник" validate(validusl("pkankfam", v-fam, output v-msgerr), v-msgerr) " " skip

  v-uslchild label "       По наличию детей" help " Отбирать/нет по данному параметру"
  v-child label "" help " 0 - детей нет, ..., 99 - просто наличие детей" " " skip

  v-uslhouse label "        По недвижимости" help " Отбирать/нет по данному параметру"
  v-house label "" help " ДА - недвижимость есть, НЕТ - нет или не указана" " " skip

  v-uslauto label "  По наличию автомашины" help " Отбирать/нет по данному параметру"
  v-auto label "" help " ДА - номером автомашины указан, НЕТ - номера нет" " " skip

  v-uslfinob label " По фин. обязательствам" help " Отбирать/нет по данному параметру"
  v-finob label "" help " ДА - обязательства есть, НЕТ - не указаны" " " skip

  v-uslacc label " По наличию банк.счетов" help " Отбирать/нет по данному параметру"
  v-acc label "" help " 0 - счетов нет, ..., 99 - просто наличие счетов" " " skip
  
  v-uslcard label "  По наличию плат. карт" help " Отбирать/нет по данному параметру"
  v-card label "" help " ДА - карточка есть, НЕТ - нет или не указана" " " skip
  
  v-uslletter label "      По наличию письма" help " Отбирать/нет по данному параметру"
  v-letter label "" help " ДА - письмо есть, НЕТ - нет или не указано" " " skip
  
with width 75 centered side-label title " УСЛОВИЯ ОТБОРА АНКЕТ " frame f-usl.

on help of v-orgs in frame f-usl do:
  run uni_book ("pkankorg", "", output v-orgs).
  displ v-orgs with frame f-usl.
end.

on help of v-pos in frame f-usl do:
  run uni_book ("pkankkat", "", output v-pos).
  displ v-pos with frame f-usl.
end.

on help of v-stag in frame f-usl do:
  run uni_book ("pkankwrk", "", output v-stag).
  displ v-stag with frame f-usl.
end.

on help of v-income in frame f-usl do:
  run uni_book ("pkankrev", "", output v-income).
  displ v-income with frame f-usl.
end.

on help of v-fam in frame f-usl do:
  run uni_book ("pkankfam", "", output v-fam).
  displ v-fam with frame f-usl.
end.

def var v-numanks as integer format "zzz,zzz,zz9" init 0.
def var v-lonyes  as integer format "zzz,zzz,zz9" init 0.
def var v-lonno   as integer format "zzz,zzz,zz9" init 0.
def var v-numrnn  as integer format "zzz,zzz,zz9" init 0.
def var v-numcif  as integer format "zzz,zzz,zz9" init 0.
def var v-ratavg  as integer format "zzz,zzz,zz9-" init 0.
def var v-ratmax  as integer format "zzz,zzz,zz9-" init 0.
def var v-ratmin  as integer format "zzz,zzz,zz9-" init 0.
def var v-rep as integer.

DEF BUTTON butsvod LABEL "СВОДКИ".
DEF BUTTON butzag  LABEL "ЗАГОЛОВКОВ".
DEF BUTTON butfull LABEL "АНКЕТ".
DEF BUTTON butexit LABEL "ВЫХОД". 
DEF BUTTON butotbor LABEL "НОВАЯ ВЫБОРКА".

form skip(1)
  v-numanks label "    Всего отобрано анкет " "   " skip
  v-lonno   label "    Из них :     отказано" "   " skip
  v-lonyes  label "          кредит разрешен" "   " skip(1)
  v-numrnn  label "    Всего уникальных РНН " "   " skip
  v-numcif  label "    Из них клиентов банка" "   " skip(1)
  v-ratavg  label "    Рейтинг :     средний" "   " skip
  v-ratmax  label "             максимальный" "   " skip
  v-ratmin  label "              минимальный" "   " skip(1)
  "------------------------------------------------" skip
  "  ПЕЧАТЬ" butsvod butzag butfull butexit
  with row 5 centered width 50 side-label overlay title " СВОДНЫЕ ДАННЫЕ ПО ВЫБОРКЕ " frame f-svod.

ON CHOOSE OF butsvod, butzag, butfull, butexit in frame f-svod do:
  case self:label : 
    when "СВОДКИ" then v-rep = 1.
    when "ЗАГОЛОВКОВ" then v-rep = 2.
    when "АНКЕТ" then v-rep = 3.
    otherwise v-rep = 0.
  end case.
END.

def frame f-newotbor
  space(15) butotbor space(5) butexit
with centered width 55 overlay row 19 title "".

ON CHOOSE OF butotbor, butexit in frame f-newotbor do:
  case self:label : 
    when "НОВАЯ ВЫБОРКА" then v-rep = 1.
    otherwise v-rep = 0.
  end case.
END.


repeat:
  v-pkankln = 0.
  v-pkankrnn = "".
  v-uslotkaz = 1.
  v-usltoday = no.
  
  v-uslref = false.
  v-uslinet = false.
  v-uslorgs = false.
  v-usldiap = false.
  v-uslperiod = false.
  v-uslrate = false.
  v-uslpos = false.
  v-uslstag = false.
  v-uslincome = false.
  v-uslfam = false.
  v-uslhouse = false.
  v-uslfinob = false.
  v-uslacc = false.
  v-uslchild = false.
  v-uslauto = false.
  v-uslcard = false.
  v-uslletter = false.

  v-orgs = "".
  v-diapb = 0.
  v-diape = 0.
  v-periodb = g-today.
  v-periode = g-today.
  v-rateb = 0.
  v-ratee = 0.
  v-pos = "".
  v-stag = "".
  v-income = "".
  v-fam = "".
  v-house = false.
  v-finob = false.
  v-acc = 0.
  v-child = 0.
  v-auto = false.
  v-card = false.
  v-letter = false.

  
  displ  
         v-pkankln     
         v-pkankrnn 
         v-usltoday
         
         v-uslref
         v-uslinet
         v-uslotkaz
         v-usldiap
         v-uslperiod
         v-uslrate

         v-uslorgs   
         v-uslpos    
         v-uslstag   
         v-uslincome
         v-uslfam   
         v-uslchild  
         v-uslhouse  
         v-uslauto   
         v-uslfinob  
         v-uslacc
         v-uslcard
         v-uslletter

         v-orgs   
         v-pos    
         v-stag   
         v-income
         v-fam   
         v-child  
         v-house  
         v-auto   
         v-finob  
         v-acc    
         v-card
         v-letter
    with frame f-usl.



  for each t-anks. delete t-anks. end.

  update v-pkankln with frame f-usl.
  if v-pkankln = 0 then do:
    update v-pkankrnn with frame f-usl.
    if v-pkankrnn = "" then do:
      update v-usltoday with frame f-usl.
      if not v-usltoday then do:
        update v-uslref
               v-uslinet
               v-uslotkaz
               v-usldiap
               v-uslperiod
               v-uslrate
               v-uslorgs   
               v-uslpos    
               v-uslstag   
               v-uslincome
               v-uslfam   
               v-uslchild  
               v-uslhouse  
               v-uslauto   
               v-uslfinob  
               v-uslacc    
               v-uslcard
               v-uslletter
          with frame f-usl.

        if v-uslorgs or v-usldiap or v-uslperiod or v-uslrate or 
           v-uslpos or v-uslstag or v-uslincome or v-uslfam or v-uslchild or
           v-uslhouse or v-uslauto or v-uslfinob or v-uslacc or v-uslcard or v-uslletter then do:
          update
               v-orgs when v-uslorgs
               v-diapb when v-usldiap v-diape when v-usldiap
               v-periodb when v-uslperiod v-periode when v-uslperiod
               v-rateb when v-uslrate v-ratee when v-uslrate
               v-pos when v-uslpos
               v-stag when v-uslstag
               v-income when v-uslincome
               v-fam when v-uslfam
               v-child when v-uslchild
               v-house when v-uslhouse
               v-auto when v-uslauto
               v-finob when v-uslfinob
               v-acc when v-uslacc
               v-card when v-uslcard
               v-letter when v-uslletter
          with frame f-usl.
        end.

        if v-usldiap then do:
          if v-diapb = 0 and v-diape = 0 then v-usldiap = false.
          else if v-diape = 0 then v-diape = v-diapb.
          if v-diapb > v-diape then v-diape = v-diapb.
        end.

        if v-uslperiod then do:
          if v-periodb > v-periode then v-periode = v-periodb.
        end.

        if v-uslrate then do:
          if v-rateb = 0 and v-ratee = 0 then v-uslrate = false.
          else if v-ratee = 0 then v-ratee = v-rateb.
          if v-rateb > v-ratee then v-ratee = v-rateb.
        end.

        /* собрать номера анкет во временную таблицу */
        for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype no-lock:
          v-ankyes = false.
          
          case v-uslotkaz:
            when 1 then v-ankyes = true.
            when 2 then v-ankyes = (pkanketa.refusal = "00") and (pkanketa.sts <> "00").
            when 3 then v-ankyes = (pkanketa.refusal <> "00") or (pkanketa.sts = "00").
          end.
          
          if v-uslref then do:
            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'rnn' no-lock no-error.
            v-ankyes = (v-ankyes and avail pkanketh and pkanketh.rescha[1] <> '').
          end.
          
          if v-uslinet then v-ankyes = (v-ankyes and v-uslinet and pkanketa.rwho = 'i-net').
          
          if v-ankyes and v-usldiap then 
            v-ankyes = pkanketa.ln >= v-diapb and pkanketa.ln <= v-diape.
          if v-ankyes and v-uslperiod then
            v-ankyes = pkanketa.rdt >= v-periodb and pkanketa.rdt <= v-periode.
          if v-ankyes and v-uslrate then
            v-ankyes = pkanketa.rating >= v-rateb and pkanketa.rating <= v-ratee.

          /* запрос на все условия - будет сочетание всех условий, т.е. AND */
          run checkank-s (v-uslorgs, v-orgs, "jobp", input-output v-ankyes).
          run checkank-s (v-uslpos, v-pos, "jobs", input-output v-ankyes).
          run checkank-s (v-uslstag, v-stag, "jobt", input-output v-ankyes).
          run checkank-s (v-uslincome, v-income, "jobpr", input-output v-ankyes).
          run checkank-s (v-uslfam, v-fam, "family", input-output v-ankyes).

          run checkank-d (v-uslchild, v-child, "child", input-output v-ankyes).
          run checkank-d (v-uslacc, v-acc, "ak1", input-output v-ankyes).

          run checkank-l (v-uslhouse, v-house, "nedv", input-output v-ankyes).
          run checkank-l (v-uslauto, v-auto, "auto", input-output v-ankyes).
          run checkank-l (v-uslcard, v-card, "ak32", input-output v-ankyes).
          
          run checkank-m (v-uslletter, v-letter, "wletter", input-output v-ankyes).
          
          run checkank-lm (v-uslfinob, v-finob, "ob.", input-output v-ankyes).

          if v-ankyes then do:
            create t-anks.
            assign t-anks.ln = pkanketa.ln
                   t-anks.rnn = pkanketa.rnn
                   t-anks.rating = pkanketa.rating.
          end.
        end.
      end.
      else do:
        /* за сегодня */
        for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rdt = today no-lock:
          create t-anks.
          assign t-anks.ln = pkanketa.ln
                 t-anks.rnn = pkanketa.rnn
                 t-anks.rating = pkanketa.rating.
        end.
      end.
    end.
    else do:
      /* по одному РНН */
      for each pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rnn = v-pkankrnn no-lock:
        create t-anks.
        assign t-anks.ln = pkanketa.ln
               t-anks.rnn = pkanketa.rnn
               t-anks.rating = pkanketa.rating.
      end.
    end.
  end.
  else do:
    /* одна анкета */
    find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = v-pkankln no-lock no-error.
    create t-anks.
    assign t-anks.ln = pkanketa.ln
           t-anks.rnn = pkanketa.rnn
           t-anks.rating = pkanketa.rating.
  end.


  /* сводные данные */

  v-lonno = 0.
  v-lonyes = 0.
  v-numrnn = 0.
  v-numcif = 0.
  v-numanks = 0.
  v-ratmax = 0.
  v-ratmin = 0.
  v-ratavg = 0.

  if can-find(first t-anks) then do:
    for each t-anks break by t-anks.rnn. 
      find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = t-anks.ln no-lock no-error.
      if (pkanketa.refusal = "00") and (pkanketa.sts <> "00") then v-lonyes = v-lonyes + 1.
                                                              else v-lonno  = v-lonno + 1.

      accumulate t-anks.ln (count).
      accumulate t-anks.rating (maximum minimum average).
      if first-of (t-anks.rnn) then do:
        v-numrnn = v-numrnn + 1.
        find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.rnn = t-anks.rnn and pkanketa.cif <> "" no-lock no-error.
        if avail pkanketa then v-numcif = v-numcif + 1.
      end.
    end.
    v-numanks = accum count t-anks.ln.
    v-ratmax = accum maximum t-anks.rating.
    v-ratmin = accum minimum t-anks.rating.
    v-ratavg = accum average t-anks.rating.
  end.

  displ v-numanks v-lonyes v-lonno v-numrnn v-numcif v-ratavg v-ratmax v-ratmin
    with frame f-svod.

  v-rep = 0.
  repeat:
    enable butsvod butzag butfull butexit with frame f-svod.

    WAIT-FOR CHOOSE OF butsvod, butzag, butfull, butexit.

    if v-rep = 0 then leave.

    find first cmp no-lock no-error.

    if v-rep = 1 then do: 
      output to repanketa.htm.
      {html-title.i 
       &stream = " "
       &title = " Сводка по выборке анкет"
       &size-add = " "
      }

      put unformatted 
      "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
      "<TR><TD>" cmp.name "<BR>" string(today, "99/99/9999") " " string(time, "HH:MM:SS") " " g-ofc "<BR></TD></TR>" skip
      "<TR><TD>" skip.

      put unformatted 
        "<P align=""center""><B>УСЛОВИЯ ОТБОРА АНКЕТ</B></P>" skip
        "<TABLE width=""80%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
        "<TR><TD><B>Условие отбора</B></TD><TD><B>отбирать/нет</B></TD><TD><B>параметр 1</B></TD><TD><B>параметр 2</B></TD></TR>" skip
        "<TR><TD>Одна анкета по номеру</TD><TD>&nbsp;</TD><TD>" string(v-pkankln) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По одному человеку (РНН)</TD><TD>&nbsp;</TD><TD>" v-pkankrnn "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>1) все 2) успешные 3) отказы</TD><TD>&nbsp;</TD><TD>" string(v-uslotkaz) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>Диапазон номеров анкет</TD><TD>" string(v-usldiap) "</TD><TD>" string(v-diapb) "</TD><TD>" string(v-diape) "</TD></TR>" skip
        "<TR><TD>Диапазон дат</TD><TD>" string(v-uslperiod) "</TD><TD>" string(v-periodb, "99/99/9999") "</TD><TD>" string(v-periode, "99/99/9999") "</TD></TR>" skip
        "<TR><TD>Диапазон рейтинга</TD><TD>" string(v-uslrate) "</TD><TD>" string(v-rateb) "</TD><TD>" string(v-ratee) "</TD></TR>" skip.

      put unformatted 
        "<TR><TD>По месту работы</TD><TD>" string(v-uslorgs) "</TD><TD>" v-orgs "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По должности</TD><TD>" string(v-uslpos) "</TD><TD>" v-pos "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По стажу работы</TD><TD>" string(v-uslstag) "</TD><TD>" v-stag "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По доходу</TD><TD>" string(v-uslincome) "</TD><TD>" v-income "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По семейному положению</TD><TD>" string(v-uslfam) "</TD><TD>" v-fam "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По наличию детей</TD><TD>" string(v-uslchild) "</TD><TD>" string(v-child) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По недвижимости</TD><TD>" string(v-uslhouse) "</TD><TD>" string(v-house) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По наличию автомашины</TD><TD>" string(v-uslauto) "</TD><TD>" string(v-auto) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По фин. обязательствам</TD><TD>" string(v-uslfinob) "</TD><TD>" string(v-finob) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По наличию банк.счетов</TD><TD>" string(v-uslacc) "</TD><TD>" string(v-acc) "</TD><TD>&nbsp;</TD></TR>" skip
        "<TR><TD>По наличию плат. карт</TD><TD>" string(v-uslcard) "</TD><TD>" string(v-card) "</TD><TD>&nbsp;</TD></TR>" skip
        "</TABLE>" skip.

      put unformatted
        "<P>&nbsp;</P><P align=""center""><B>СВОДНЫЕ ДАННЫЕ ПО ВЫБОРКЕ</B></P>" skip
        "<TABLE width=""50%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
        "<TR><TD>Всего отобрано анкет</TD><TD>" string(v-numanks) "</TD></TR>" skip
        "<TR><TD>Из них отказов</TD><TD>" string(v-lonno) "</TD></TR>" skip
        "<TR><TD>кредитов</TD><TD>" string(v-lonyes) "</TD></TR>" skip
        "<TR><TD>Всего уникальных РНН</TD><TD>" string(v-numrnn) "</TD></TR>" skip
        "<TR><TD>Из них клиентов банка</TD><TD>" string(v-numcif) "</TD></TR>" skip
        "<TR><TD>Рейтинг : средний</TD><TD>" string(v-ratavg) "</TD></TR>" skip
        "<TR><TD>максимальный</TD><TD>" string(v-ratmax) "</TD></TR>" skip
        "<TR><TD>минимальный</TD><TD>" string(v-ratmin) "</TD></TR>" skip.

      put unformatted 
        "</TD></TR>"
        "</TABLE>" skip.

      {html-end.i " " }

      output close.
      unix silent cptwin repanketa.htm excel.
    end.

    if v-rep = 2 then run pkankvwlst ("СПИСОК ОТОБРАННЫХ АНКЕТ").

    if v-rep = 3 then run pkankvw ("ОТОБРАННЫЕ АНКЕТЫ").

  end.

  hide frame f-svod.


  v-rep = 0.
  enable all with frame f-newotbor.

  WAIT-FOR CHOOSE OF butotbor, butexit.
  hide frame f-newotbor.

  if v-rep = 0 then leave.
end.


hide all no-pause.

/* ======================================================================================== */

procedure checkank-s. 
  def input parameter p-usl as logical.
  def input parameter p-usldata as char.
  def input parameter p-krit as char.
  def input-output parameter p-ankyes as logical.


  if p-ankyes and p-usl then do:
    if p-usldata = "" or lookup("msc", p-usldata) > 0 then do:
      find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and 
          pkanketh.ln = pkanketa.ln and pkanketh.kritcod = p-krit no-lock no-error.
      p-ankyes = not avail pkanketh.
      if not p-ankyes then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype 
             and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = p-krit and 
             (pkanketh.value1 = "" or pkanketh.value1 = "msc") 
             no-lock no-error.
        p-ankyes = avail pkanketh.
      end.
    end.
    else do:
      find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and 
           pkanketh.ln = pkanketa.ln and 
           pkanketh.kritcod = p-krit and lookup(pkanketh.value1, p-usldata) > 0 no-lock no-error.
      p-ankyes = p-ankyes and avail pkanketh.
    end.
  end.
end procedure.

procedure checkank-d. 
  def input parameter p-usl as logical.
  def input parameter p-usldata as integer.
  def input parameter p-krit as char.
  def input-output parameter p-ankyes as logical.

  if p-ankyes and p-usl then do:
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and 
         pkanketh.ln = pkanketa.ln and 
         pkanketh.kritcod = p-krit and 
         if p-usldata = 99 then integer(pkanketh.value1) > 0 
         else integer(pkanketh.value1) = p-usldata
         no-lock no-error.
    p-ankyes = (avail pkanketh) or ((not avail pkanketh) and (p-usldata = 0)).
  end.
end procedure.


procedure checkank-l. 
  def input parameter p-usl as logical.
  def input parameter p-usldata as logical.
  def input parameter p-krit as char.
  def input-output parameter p-ankyes as logical.

  if p-ankyes and p-usl then do:
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and 
         pkanketh.ln = pkanketa.ln and 
         pkanketh.kritcod = p-krit and integer(pkanketh.value1) > 0 no-lock no-error.
    p-ankyes = (p-usldata = avail pkanketh).
  end.
end procedure.


procedure checkank-lm. 
  def input parameter p-usl as logical.
  def input parameter p-usldata as logical.
  def input parameter p-krit as char.
  def input-output parameter p-ankyes as logical.

  if p-ankyes and p-usl then do:
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and 
           pkanketh.ln = pkanketa.ln and 
           pkanketh.kritcod matches p-krit and integer(pkanketh.value1) > 0 no-lock no-error.
    p-ankyes = (p-usldata = avail pkanketh).
  end.
end procedure.

procedure checkank-m.
  def input parameter p-usl as logical.
  def input parameter p-usldata as logical.
  def input parameter p-krit as char.
  def input-output parameter p-ankyes as logical.

  if p-ankyes and p-usl then do:
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and 
         pkanketh.ln = pkanketa.ln and 
         pkanketh.kritcod = p-krit no-lock no-error.
    if avail pkanketh then do:
      if not(trim(pkanketh.value1) = '' or caps(trim(pkanketh.value1)) = "НЕТ") then p-ankyes = true.
      else p-ankyes = false.
    end.
    else p-ankyes = false.
  end.
end procedure.
