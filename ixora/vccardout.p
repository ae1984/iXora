/* vccardout.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложения 7 - лицевая карточка клиента
 * RUN
        
 * CALLER
        vcrep1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
 
 * BASES
         BANK COMM  
        
 * AUTHOR
        20.05.2008 galina
 * CHANGES
        14.08.2009 galina - добавила вывод коментария для ЛКБК
     
        */

{vc.i}

{global.i}

def input parameter p-filename as char.
def input parameter p-cardnum as char.
def input parameter p-cardreason as char.
def input parameter p-rem as char.

def shared temp-table t-docs 
  field clcif like cif.cif
  field clname like cif.name
  field okpo as char format "999999999999"
  field rnn as char format "999999999999"
  field clntype as char
  field address as char
  field region as char
  field psnum as char 
  field psdate as date 
  field bankokpo as char
  field ctexpimp as char
  field ctnum as char
  field ctdate as date
  field ctsum as char
  field ctncrc as char
  field partner like vcpartners.name
  field countryben as char
  field ctterm as char
  field dolgsum as char
  field dolgsum_usd as char
  field cardsend like vccontrs.cardsend
  field valterm as integer
  field prefix as char
  index main is primary clcif ctdate ctsum.
  
def shared temp-table t-cif
  field clcif like cif.cif
  field clname like cif.name
  field okpo as char format "999999999999"
  field rnn as char format "999999999999"
  field clntype as char
  field address as char
  field region as char
  field psnum as char 
  field psdate as date 
  field bankokpo as char
  field ctexpimp as char
  field ctnum as char
  field ctdate as date
  field ctsum as char
  field ctncrc as char
  field partner like vcpartners.name
  field countryben as char
  field ctterm as char
  field cardsend like vccontrs.cardsend
  field prefix as char
  index main is primary clcif ctdate ctsum.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var i as integer no-undo.
def var v-monthname as char init
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".

   

def stream vcrpt.
output stream vcrpt to value(p-filename).


find first cmp no-lock no-error.

{html-title.i 
 &stream = " stream vcrpt "
 &size-add = "xx-"
 &title = "Приложения 7 "
}

  put stream vcrpt unformatted
     "<B>" skip
     "<P align = ""right""><FONT size=""1"" face=""Times New Roman Cyr, Verdana, sans""><I>"
       "ПРИЛОЖЕНИЕ 7<BR>"
       "к Правилам осуществления экспортно-импортного валютного контроля в РК<BR>"
       "</I></FONT></P>" skip
       "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
       "Лицевая карточка банковского контроля № "  + p-cardnum + "<br>отчетный месяц " + entry(v-month, v-monthname) + " "
        + "год " + string(v-god, "9999") + "</FONT></P>" skip.

find first t-docs no-lock no-error.
if avail t-docs then do:
for each t-docs no-lock:
  put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
     "<TD>№</TD>" skip
     "<TD>Наименование информации по лицевой<br>карточке банковского контроля</TD>" skip
     "<TD>Код<BR>строки</TD>" skip
     "<TD>Информация по лицевой<BR>карточке банковского контроля</TD></TR>" skip.
 
    run outputrow (1, "Основание направления лицевой<BR>карточки:", 10, p-cardreason).
    run outputrow (2, "Информация по экспортеру<br>или импортеру:", 20, " ").
    run outputrow (3, "Наименование<BR>или<BR>фамилия, имя, отчество", 21, t-docs.clname).
    run outputrow (4, "Код<BR>ОКПО", 22, t-docs.okpo).
    run outputrow (5, "РНН", 23,  "&nbsp;" + t-docs.rnn ).
    run outputrow (6, "Признак-юридическое лицо или<BR>инивидуальный предприниматель", 24, t-docs.clntype).
    run outputrow (7, "Адрес", 25, t-docs.address).
    run outputrow (8, "Код<BR>области", 26, t-docs.region).
    run outputrow (9, "Паспорт сделки:", 30, "").
    run outputrow (10, "Номер", 31, t-docs.psnum).
    if t-docs.psdate = ? then run outputrow (11, "Дата", 32, " ").
    else run outputrow (11, "Дата", 32, string(t-docs.psdate, "99/99/99")).
    run outputrow (12, "Код ОКПО банка<br>паспорта сделки", 40, t-docs.bankokpo).
    run outputrow (13, "Информация по контракту", 50, "").
    run outputrow (14, "Признак - экспорт<BR>или импорт", 51, t-docs.ctexpimp).
    run outputrow (15, "Номер", 52, t-docs.ctnum).
    run outputrow (16, "Дата", 53, t-docs.ctdate).
    run outputrow (17, "Сумма в тысячах единиц", 54, t-docs.ctsum).
    run outputrow (18, "Валюта контракта", 55, t-docs.ctncrc).
    run outputrow (19, "Информация по нерезиденту", 60, " ").
    run outputrow (20, "Наименование<BR>или<BR>фамилия, имя, отчество", 61, t-docs.partner).
    run outputrow (21, "Страна", 62, t-docs.countryben).
    run outputrow (22, "Ориентировочные сроки<br>поступления валюты", 70, string(t-docs.ctterm, '999.9')).
    run outputrow (23, "Информация о сумме неисполненных<br>обязательств нерезидента по контракту<br>в ориентировочные сроки поступления<br>валюты перед экспортером или <br>импортером", 80, " ").
    
    if (index(p-cardreason, '1') > 0 or index(p-cardreason, '5') > 0) then do: 
       run outputrow (24, "В валюте контракта", 81, t-docs.dolgsum).
       run outputrow (25, "В долларах США", 82, t-docs.dolgsum_usd).
    end.
    else do: 
       run outputrow (24, "В валюте контракта", 81, "").
       run outputrow (25, "В долларах США", 82, "").
    end.
    run outputrow (26, "Примечание", 90, p-rem).
 
end.
end.

else do:
find first t-cif no-lock no-error.
if avail t-cif then do:
for each t-cif no-lock:
  put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
     "<TD>№</TD>" skip
     "<TD>Наименование информации по лицевой<br>карточке банковского контроля</TD>" skip
     "<TD>Код<BR>строки</TD>" skip
     "<TD>Информация по лицевой<BR>карточке банковского контроля</TD></TR>" skip.
 
    run outputrow (1, "Основание направления лицевой<BR>карточки:", 10, p-cardreason).
    run outputrow (2, "Информация по экспортеру<br>или импортеру:", 20, " ").
    run outputrow (3, "Наименование<BR>или<BR>фамилия, имя, отчество", 21, t-cif.clname).
    run outputrow (4, "Код<BR>ОКПО", 22, t-cif.okpo).
    run outputrow (5, "РНН", 23,  "&nbsp;" + t-cif.rnn ).
    run outputrow (6, "Признак-юридическое лицо или<BR>инивидуальный предприниматель", 24, t-cif.clntype).
    run outputrow (7, "Адрес", 25, t-cif.address).
    run outputrow (8, "Код<BR>области", 26, t-cif.region).
    run outputrow (9, "Паспорт сделки:", 30, "").
    run outputrow (10, "Номер", 31, t-cif.psnum).
    if t-cif.psdate = ? then run outputrow (11, "Дата", 32, " ").
    else run outputrow (11, "Дата", 32, string(t-cif.psdate, "99/99/99")).
    run outputrow (12, "Код ОКПО банка<br>паспорта сделки", 40, t-cif.bankokpo).
    run outputrow (13, "Информация по контракту", 50, "").
    run outputrow (14, "Признак - экспорт<BR>или импорт", 51, t-cif.ctexpimp).
    run outputrow (15, "Номер", 52, t-cif.ctnum).
    run outputrow (16, "Дата", 53, t-cif.ctdate).
    run outputrow (17, "Сумма в тысячах единиц", 54, t-cif.ctsum).
    run outputrow (18, "Валюта контракта", 55, t-cif.ctncrc).
    run outputrow (19, "Информация по нерезиденту", 60, " ").
    run outputrow (20, "Наименование<BR>или<BR>фамилия, имя, отчество", 61, t-cif.partner).
    run outputrow (21, "Страна", 62, t-cif.countryben).
    run outputrow (22, "Ориентировочные сроки<br>поступления валюты", 70, string(t-cif.ctterm, '999.9')).
    run outputrow (23, "Информация о сумме неисполненных<br>обязательств нерезидента по контракту<br>в ориентировочные сроки поступления<br>валюты перед экспортером или <br>импортером", 80, " ").
    run outputrow (24, "В валюте контракта", 81, "").
    run outputrow (25, "В долларах США", 82, "").
    run outputrow (26, "Примечание", 90, p-rem).
 
end.
end.
end.
put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i}

output stream vcrpt close.
  unix silent value("cptwin " + p-filename + " winword.exe").
pause 0.


procedure outputrow.
def input parameter p-i as integer. 
def input parameter p-strname as char.
def input parameter p-strcode as integer.
def input parameter p-strval as char.

 put stream vcrpt unformatted       
    "<TR align=""center"" style=""font:bold"">" skip                                          
        "<TD>" p-i "</TD>" skip
        "<TD>" p-strname "</TD>" skip
        "<TD>" p-strcode "</TD>" skip
        "<TD>" p-strval "</TD>" skip
        "</TR>" skip.
end.        