/* astnalpy.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

/*
  Декларация по налогу на имущество за год
*/

def var cstr as char extent 18 init ['001','002','003','004','005','006','007','008','009','010','011','012','013','014',
                                     '015','016','017','018'].
def var mstr as char extent 18 init ['на начало налогового периода','фев','мар','апр','май','июн','июл','авг','сен','окт','ноя','дек',
                                     'на конец налогового периода'].

def temp-table tst  /* остаточная стоимость на дату (начало периода)*/
    field osnsr  as decimal format "zzz,zzz,zzz,zzz,zz9.99"  /* основные средства*/
    field nematk as decimal format "zzz,zzz,zzz,zzz,zz9.99" /* нематериальные активы*/
    field dt as date.         /* дата */

def var vmc as date.
def var dyear as integer init 2008.
def var i as integer.
def var j as integer.

def temp-table a
    field ast like astatl.ast
    field gl like astatl.agl 
    field bal like astatl.atl
    field dt as date.

update "Введите год" dyear no-label format "zzzz" auto-return.

/*display STRING(TIME,"HH:MM:SS") skip.*/

do i = 1 to 12:

    vmc = date(i,1,dyear).
    create tst.
    tst.dt = vmc.

    for each ast:
      find last astatl where astatl.ast = ast.ast and astatl.dt < vmc use-index astdt no-lock no-error.
      if available astatl 
         then 
           do:
              create a.
              a.ast = astatl.ast.
              a.gl = astatl.agl.
              a.bal = astatl.atl.
              a.dt = vmc.
           end.
    end.   
end.

dyear = dyear + 1.
i = 1.

    vmc = date(i,1,dyear).
    create tst.
    tst.dt = vmc.

    for each ast:
      find last astatl where astatl.ast = ast.ast and astatl.dt < vmc use-index astdt no-lock no-error.
      if available astatl 
         then 
           do:
              create a.
              a.ast = astatl.ast.
              a.gl = astatl.agl.
              a.bal = astatl.atl.
              a.dt = vmc.
           end.
    end.   



/*display STRING(TIME,"HH:MM:SS") skip.*/

for each a where a.gl = 165200 or a.gl = 165300 or a.gl = 165420 or a.gl = 165440 break by a.dt:
    accumulate a.bal   (sub-total by a.dt). 
    if last-of (a.dt)
       then
         do:
            find tst where tst.dt = a.dt exclusive-lock no-error.
            if not avail tst
               then 
                 do:
                    create tst.
                    tst.dt = a.dt.
                 end.
            tst.osnsr = accum sub-total by a.dt a.bal.
            find current tst no-lock.
         end.
end.

for each a where a.gl = 165910 or a.gl = 165920 or a.gl = 169920 break by a.dt:
    accumulate a.bal   (sub-total by a.dt). 
    if last-of (a.dt)
       then
         do:
            find tst where tst.dt = a.dt exclusive-lock no-error.
            if not avail tst
               then 
                 do:
                    create tst.
                    tst.dt = a.dt.
                 end.
            tst.nematk = accum sub-total by a.dt a.bal.
            find current tst no-lock.
         end.
end.


output to 'astnalpy.html'.

{html-title.i &stream = " " &title = "Декларация по налогу на имущество" &size-add = " "}

put unformatted 
   "<P align = ""center""><FONT size=5 face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Декларация по налогу на имущество<BR>" "</B></FONT></P>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

put unformatted "<TR> <TD ALIGN=CENTER COLSPAN=4> <FONT size=4> Раздел Исчисление остаточной стоимости основных средств и нематериальных активов </FONT> </TD>" "</TR>" skip.
put unformatted "<TR> <TD ALIGN=CENTER > Код строки " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Наименование " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Остаточная стоимость основных средств" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Остаточная стоимость нематериальных активов" "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > A" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > B" "</TD>" skip.
put unformatted "</TR>"  skip.

i = 1.

for each tst:
  j = month(tst.dt).
  if i < 13 then put unformatted "<TR> <TD ALIGN=CENTER > 700.03." cstr[j] "</TD>" skip.
            else put unformatted "<TR> <TD ALIGN=CENTER > 700.03." cstr[i] "</TD>" skip.
  case i: 
    when 1  then put unformatted "<TD ALIGN=CENTER > на начало налогового периода" "</TD>" skip.
    when 13 then put unformatted "<TD ALIGN=CENTER > на конец налогового периода " "</TD>" skip.
    OTHERWISE put unformatted "<TD ALIGN=RIGHT > 01." mstr[j] "</TD>" skip.
  end case.

  put unformatted "<TD ALIGN=CENTER > " string(tst.osnsr,"zzz,zzz,zzz,zz9.99")  "</TD>" skip.
  put unformatted "<TD ALIGN=CENTER > " string(tst.nematk,"zzz,zzz,zzz,zz9.99")  "</TD>" skip.
  put unformatted "</TR>"  skip.

  i = i + 1.
  accumulate tst.osnsr (TOTAL).
  accumulate tst.nematk (TOTAL).
end.


put unformatted "<TR> <TD ALIGN=CENTER > 700.03." cstr[14] "</TD>" skip.
put unformatted "<TD ALIGN=RIGHT > Всего"  "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(accum total tst.osnsr,"zzz,zzz,zzz,zz9.99")  "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > " string(accum total tst.nematk,"zzz,zzz,zzz,zz9.99")  "</TD>" skip.
put unformatted "</TR>"  skip.


def var msum as integer.


msum = ((accum total tst.osnsr) + (accum total tst.nematk)) / 13.


/*put unformatted "</TABLE> <BR>" skip.

put unformatted "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.*/

put unformatted "<TR> <TD ALIGN=CENTER COLSPAN=4> <FONT size=4> Раздел Исчисление налога на имущество </FONT> </TD>" "</TR>" skip.
put unformatted "<TR> <TD ALIGN=CENTER > 700.03." cstr[16] "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Среднегодовая остаточная стоимость основных средств и нематериальных активов" "</TD>" skip.
put unformatted "<TD ALIGN=CENTER COLSPAN=2> " string(msum,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > 700.03." cstr[17] "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Ставка налога"  "</TD>" skip.
put unformatted "<TD ALIGN=CENTER COLSPAN=2> 1%" "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "<TR> <TD ALIGN=CENTER > 700.03." cstr[18] "</TD>" skip.
put unformatted "<TD ALIGN=CENTER > Сумма налога"  "</TD>" skip.
put unformatted "<TD ALIGN=CENTER COLSPAN=2> " string(msum / 100 ,"zzz,zzz,zzz,zz9.99") "</TD>" skip.
put unformatted "</TR>"  skip.

put unformatted "</TABLE> <BR>" skip.

{html-end.i " "}
output close.            

unix silent value("cptwin astnalpy.html iexplore").

pause 0.
