/* bkorder.p
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Заказ в АБН безымянных карточек для БД
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
        17.12.05 marinav 
 * CHANGES
        18/01/06
        07/09/06 marinav - убраны whole-index 
*/

{bk.i}

{global.i}

def var s_rowid1 as rowid.
def var s_rowid2 as rowid.
def var i as inte.
def var v_id as inte.
def var v_nominal as inte.
def var s_bank as char.
def var v_point as inte.
def var l_exe as logical.
def var v_count as inte.
def var v_nom as inte.

def buffer b_bkorder for bkorder.


define query q1 for bkorder .
define browse b1 query q1 
              display
                 bkorder.nom     format ">>>9"        label "Заказ"
                 bkorder.bank    format "x(6)"        label "Филиал"
                 bkorder.nominal format ">>>,>>>,>>9" label "Номинал карты"
                 bkorder.counts  format ">>>>"        label "Количество" 
                 bkorder.execute                      label "Исполнен" 
                 bkorder.who                          label "Менеджер" 
                 bkorder.whn                          label "Дата" 
                 with 15 down no-labels.
define frame fr1 b1 
    help "<ENTER>-Редак, <TAB>-Экспресс-точки, <INS>-Новый заказ, <F8>-Удалить, <F4> Выход" with side-labels centered title "ЗАКАЗЫ КАРТ" row 2 .

define query q2 for bkorder .
define browse b2 query q2 
              display
                /* bkorder.id      format ">>>9"        label "Заказ"
                 bkorder.bank    format "x(6)"        label "Филиал"
                 bkorder.nominal format ">>>,>>>,>>9" label "Номинал карты"*/
                 bkorder.point        format ">>>>"    no-label
                 bkorder.name_point   format "x(20)"   label "Экспресс-точка" 
                 bkorder.counts       format ">>>>"    label "Колич." 
                 bkorder.execute                       label "Исполнен" 
                 bkorder.who                           label "Менеджер" 
                 bkorder.whn                           label "Дата" 
                 with 13 down no-labels.

DEFINE BUTTON bprt LABEL "Сформировать акты".        

define frame fr2 b2   help "<ENTER>-Редак, <INS>-Новая точка, <F8>-Удалить, <F4> Выход" 
                 bprt help "Формирование акта приема-передачи для экспресс-точки" 
                 with side-labels centered 
                 title "Заказ карт N-" + string(v_nom) + " для " + s_bank + " номиналом " + string(v_nominal) + " тенге" row 2 .


define frame fr-1
       skip(1)
       bkorder.nominal format ">>>,>>>,>>9" label "Номинал     " skip
       bkorder.counts  format ">>>>"        label "Количество  "  skip(1)
       with side-label centered row 5 title "Введите номинал карты и количество" .


define frame fr-2
       skip(1)
       bkorder.point        format ">>>>"  label "Экспресс-точка  " skip
       bkorder.counts       format ">>>>"  label "Количество      "  skip(1)
       with side-label centered row 5 title "Введите номер точки и количество" .


ON CHOOSE OF bprt IN FRAME fr2
    do:
        /* Проверим, все ли заказанные карты имеют номер (тот, 16-значный, из АВН. Если нет, то поищем их по RBS в card_status и если найдем, проставим номер карты в bkcard 
           Или это будет дополнительный файл поступающий с респонзом?... */

        /* Дадим branch`ам номера карт (запишем номера в info1) и распечатаем акты. Перед этим проверим , чтобы заказ был исполнен - bkorder.execute = yes. 
           Здесь же (может быть...) отправим файл в АБН для смены branch`a */
       if bkorder.execute = yes then do:
           if bkorder.info1 = '' then run prnakt.
                                 else run prnakt_dubl.
       end.
       else 
         MESSAGE skip "Карты не были заказаны ! Сначала отправьте заказ в АБН !!!"
         VIEW-AS ALERT-BOX 
         TITLE "ПЕЧАТЬ АКТОВ" .
       b2:refresh().
    end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.


on "return" of browse b1
do:
   find first b_bkorder where b_bkorder.point = 0 no-lock no-error.
   if avail b_bkorder then do:
     if bkorder.execute = yes then 
         MESSAGE skip "Редактировать нельзя - заказ исполнен!"
         VIEW-AS ALERT-BOX 
         TITLE "ЗАКАЗ НА КАРТУ" .
     else do:
        s_rowid1 = rowid(bkorder).
        find current bkorder  exclusive-lock no-error.
        update bkorder.nominal bkorder.counts with frame fr-1.
        
        close query q1. 
        assign bkorder.who = g-ofc
               bkorder.whn = g-today.
        open query q1 for each bkorder where bkorder.point = 0 no-lock by bkorder.id.
        reposition q1 to rowid s_rowid1.
        /*  browse b1:select-row(CURRENT-RESULT-ROW("q1")).*/
        browse b1:refresh().
     end.
   end.
end.

on "return" of browse b2
do:
   find first b_bkorder where b_bkorder.id = v_id and b_bkorder.point > 0 no-lock no-error.
   if avail b_bkorder and bkorder.info1 = '' then do:
     s_rowid2 = rowid(bkorder).
     find current bkorder  exclusive-lock no-error.
     update bkorder.point bkorder.counts with frame fr-2.
     
     close query q2. 
     assign bkorder.who = g-ofc
            bkorder.whn = g-today
            bkorder.id = v_id
            bkorder.nominal = v_nominal
            bkorder.execute = l_exe
            bkorder.bank = s_bank.
     find first spr where spr.sprcod = 'bkpoint' and spr.code = string(bkorder.point) no-lock no-error.
     if avail spr then bkorder.name_point = spr.name.
     for each b_bkorder where b_bkorder.id = v_id and b_bkorder.point > 0 break by b_bkorder.id by b_bkorder.point .
        accumulate b_bkorder.count(total by b_bkorder.id by b_bkorder.point).
     end.
     if (accum total b_bkorder.count) > v_count then 
             MESSAGE skip "Общее количество карт превышает заказ!" + string(accum total b_bkorder.count) + string(v_count)
             VIEW-AS ALERT-BOX 
             TITLE "ЗАКАЗ ПО ТОЧКАМ" .
     open query q2 for each bkorder where bkorder.id = v_id and bkorder.point > 0 no-lock.
     reposition q2 to rowid s_rowid2.
     /*  browse b1:select-row(CURRENT-RESULT-ROW("q1")).*/
     browse b2:refresh().
   end.
   else 
         MESSAGE skip "Редактировать нельзя - акты уже были сформированы!"
         VIEW-AS ALERT-BOX 
         TITLE "ЗАКАЗ НА КАРТУ" .
end.

on "INS" of browse b1
do:
   create bkorder.
   s_rowid1 = rowid(bkorder).
   find current bkorder  exclusive-lock no-error.
   update bkorder.nominal bkorder.counts with frame fr-1.
   
   close query q1. 
   assign bkorder.who = g-ofc
          bkorder.whn = g-today
          bkorder.id = next-value(idorder)
          bkorder.point = 0
          bkorder.bank = s_bank.
   open query q1 for each bkorder where bkorder.point = 0 no-lock by bkorder.id.
   reposition q1 to rowid s_rowid1.
 /*  browse b1:select-row(CURRENT-RESULT-ROW("q1")).*/
   browse b1:refresh().
end.

on "INS" of browse b2
do:
   create bkorder.
   s_rowid2 = rowid(bkorder).
   find current bkorder  exclusive-lock no-error.
   update bkorder.point bkorder.counts with frame fr-2.
   /*find first b_bkorder where b_bkorder.id = v_id and b_bkorder.point = bkorder.point no-lock no-error.
   if avail b_bkorder then 
             MESSAGE skip "На эту точку уже есть заказ ! Увеличьте в нем количество карт..."
             VIEW-AS ALERT-BOX 
             TITLE "ЗАКАЗ ПО ТОЧКАМ" .
   else do:*/
      close query q2. 
      assign bkorder.who = g-ofc
             bkorder.whn = g-today
             bkorder.id = v_id
             bkorder.nominal = v_nominal
             bkorder.execute = l_exe
             bkorder.bank = s_bank.
             bkorder.nom = v_nom.
      find first spr where spr.sprcod = 'bkpoint' and spr.code = string(bkorder.point) no-lock no-error.
      if avail spr then bkorder.name_point = spr.name.
      for each b_bkorder where b_bkorder.id = v_id and b_bkorder.point > 0 break by b_bkorder.id by b_bkorder.point .
           accumulate b_bkorder.count(total by b_bkorder.id by b_bkorder.point).
      end.
      if (accum total b_bkorder.count) > v_count then 
                MESSAGE skip "Общее количество карт превышает заказ!" + string(accum total b_bkorder.count) + string(v_count)
                VIEW-AS ALERT-BOX 
                TITLE "ЗАКАЗ ПО ТОЧКАМ" .
      open query q2 for each bkorder where bkorder.id = v_id and bkorder.point > 0 no-lock.
      reposition q2 to rowid s_rowid2.                    
      /*  browse b1:select-row(CURRENT-RESULT-ROW("q1")).*/
   
   browse b2:refresh().
end.

on "TAB" of browse b1
do:
   s_rowid1 = rowid(bkorder).
   v_id = bkorder.id.
   v_nominal = bkorder.nominal.
   l_exe = bkorder.execute.
   v_count = bkorder.count.
   v_nom = bkorder.nom.
   open query q2 for each bkorder where bkorder.id = v_id and bkorder.point > 0 no-lock.
   enable all with frame fr2.
   wait-for "PF4" of frame fr2 focus browse b2.
   open query q1 for each bkorder where bkorder.point = 0  no-lock by bkorder.id.
   reposition q1 to rowid s_rowid1.
/*   browse b1:select-row(CURRENT-RESULT-ROW("q1")).*/
   browse b1:refresh().

end.

on "clear" of browse b1
do:
    if bkorder.execute = no then do:
    MESSAGE skip "Удалить?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "ЗАКАЗ НА КАРТУ" UPDATE choice as logical.
          if choice = true then do:
            s_rowid1 = rowid(bkorder).
            v_id = bkorder.id.
            for each bkorder where bkorder.id = v_id EXCLUSIVE-LOCK.
                delete bkorder.
            end.
            open query q1 for each bkorder where bkorder.point = 0 no-lock.
          end.
    end.
    else 
    MESSAGE skip "Удалить невозможно - заказ исполнен!"
    VIEW-AS ALERT-BOX 
    TITLE "ЗАКАЗ НА КАРТУ" .
end.

on "clear" of browse b2
do:
    MESSAGE skip "Удалить?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "ЗАКАЗ НА КАРТУ" UPDATE choice as logical.
          if choice = true then do:
            if bkorder.info1 = '' then do:
               find current bkorder exclusive-lock. 
               delete bkorder.
               open query q2 for each bkorder where bkorder.id = v_id and bkorder.point > 0 no-lock.
            end. else 
                 MESSAGE skip "Удалить невозможно - филиал (заказ) закреплен за картами !"
                 VIEW-AS ALERT-BOX 
                 TITLE "ЗАКАЗ НА КАРТУ" .
             /* можно удалить этот филиал, но только если в соответствующих bkcard статус sta ne 2 (сведения о вранче ушли в АБН)
               со временем можно учитывать и это - удалять и в АБН засылать новый бранч */
          end.
end.

on help of bkorder.point in frame fr-2 do:
     {itemlist.i 
       &file = "spr"
       &frame = "  row 5 centered scroll 1 10 down overlay title ' ЭКСПРЕСС-ТОЧКИ ' "
       &where = " spr.sprcod = 'bkpoint' "
       &flddisp = "spr.code label 'Точка'
                   spr.name FORMAT 'x(50)' label 'Название' " 
       &chkey = "code "
       &chtype = "string"
       &index  = "main" }

     bkorder.point = inte(spr.code) .
     displ bkorder.point with frame fr-2.
end.

on help of bkorder.nominal in frame fr-1 do:
     {itemlist.i 
       &file = "spr"
       &frame = "  row 5 centered scroll 1 10 down overlay title ' НОМИНАЛЫ КАРТ ' "
       &where = " spr.sprcod = 'bknomin' "
       &flddisp = "spr.code label 'Номинал'
                   spr.name FORMAT 'x(50)' label '' " 
       &chkey = "code "
       &chtype = "string"
       &index  = "main" }

     bkorder.nominal = inte(spr.code) .
     displ bkorder.nominal with frame fr-1.
end.


   open query q1 for each bkorder where bkorder.point = 0 no-lock by bkorder.id.
   enable all with frame fr1.
   wait-for "PF4" of frame fr1 focus browse b1.



procedure prnakt.

output to ord1.html.

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
    "<br><P align=""left"" style=""font:bold"">Сведения о заказанных картах</P>" skip.

put  unformatted     
                   "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                    "<td rowspan=2 align=center>Номер карты</td>"
                    "<td rowspan=2 align=center>Номинал карты</td>"
                  "</tr><tr></tr>" skip.

     find current bkorder  exclusive-lock no-error.
        repeat i = 1 to bkorder.counts:
           find first bkcard where bkcard.nom = bkorder.nom and bkcard.bank = s_bank and bkcard.nominal = bkorder.nominal and bkcard.point = 0 exclusive-lock no-error.
           if avail bkcard then do:
              bkcard.point = bkorder.point.
              find current bkcard no-lock no-error.
              put unformatted 
                   "<TR><TD >&nbsp;" string(bkcard.contract_number) format "x(16)" "</TD>" skip
                   "<TD>" bkorder.nominal "</TD>" skip
                   "</TR>" skip.

              bkorder.info1 =  bkorder.info1 + bkcard.rbs + ','.
           end.
        end.
        find current bkorder  no-lock no-error.


put unformatted "</table>" skip.
put unformatted "</table></body></html>" skip.
output close.
unix silent cptwin ord1.html excel.exe.

end.


procedure prnakt_dubl.

output to ord1.html.

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted  "<br><P align=""left"" style=""font:bold"">Сведения о заказанных картах</P>" skip.

put  unformatted    "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                    "<td rowspan=2 align=center>Номер карты</td>"
                    "<td rowspan=2 align=center>Номинал карты</td>"
                  "</tr><tr></tr>" skip.

           for each bkcard where bkcard.nom = bkorder.nom and bkcard.bank = s_bank and bkcard.nominal = bkorder.nominal and bkcard.point = bkorder.point no-lock.
              put unformatted 
                   "<TR><TD >&nbsp;" string(bkcard.contract_number)  format "x(16)"  "</TD>" skip
                   "<TD>" bkorder.nominal "</TD>" skip
                   "</TR>" skip.
           end.

put unformatted "</table>" skip.
put unformatted "</table></body></html>" skip.
output close.
unix silent cptwin ord1.html excel.exe.

end.

