/* r-astmrp.p
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
	24/05/04 valery 40 МРП заменено на 50 МРП, в связи с изменением законодательства по просьбе Лии И.
*/
	

/* r-astmrp.p 
   Основные средства, стоимость < 40 МРП
   16.02.2001  */


def var     v-kvart  as   integer.
def var     v-year   as   integer    format '9999'.
def var     v-dat1   as   date.
def var     v-dat2   as   date.
def var     s-mrp    as   decimal    extent 4.
def var     s-icost  like ast.icost  init 0.
def var     s-nol    like ast.icost  init 0.
def var     s-atl    like ast.icost  init 0.
def var     ii       as   integer    init 0.
def var     usl      as   logical    init false.
def stream  m-out.

{global.i}
{functions-def.i}

if month(g-today) ge 1 and month(g-today) le 3 then v-kvart = 1.
   else if month(g-today) ge 4 and month(g-today) le 6 then v-kvart = 2.
   else if month(g-today) ge 7 and month(g-today) le 9 then v-kvart = 3.
   else v-kvart = 4.
v-year = year(g-today).

update v-kvart 
       validate(v-kvart ge '0'and v-kvart le '4',
       ' Недопустимое значение! ')
       help '1,2,3,4 - на соотвествующий квартал; 0 - на весь год'
       label ' Укажите: квартал '
       v-year  
       validate(v-year ge 1995 and v-year le year(g-today) ,
       ' Недопустимое значение! ')
       label ' год ' .

hide all.
display '   Ждите...   '  with row 5 frame ww centered .

output stream m-out to rpt.img.

if v-kvart = 0 then do.
  v-dat1 = date(1,1,v-year).
  v-dat2 = date(1,1,v-year + 1).
end.     
else if v-kvart <> 4 then do.
        v-dat1 = date(v-kvart * 3 - 2,1,v-year).
        v-dat2 = date(v-kvart * 3 + 1,1,v-year).
     end.
     else do.
        v-dat1 = date(v-kvart * 3 - 2,1,v-year).
        v-dat2 = date(1,1,v-year + 1).
     end.   

if v-kvart <> 0 then do.
   find astmrp where r-year = string(v-year) and r-kvart = string(v-kvart)
        no-lock no-error.
   if not avail astmrp then do.
      find astmrp where r-year = string(v-year) and r-kvart = '0'
           no-lock no-error.
           if not avail astmrp then do.
              message 'В справочнике МРП отсутствуют данные за ' v-kvart 'квартал или в целом за ' v-year 'год.' .
              return.
           end.    
   end.
   s-mrp[v-kvart] = r-sum * 50.
end.
else do.
   ii = 0.
   repeat while ii < 5.
     find astmrp where r-year = string(v-year) and r-kvart = string(ii)
          no-lock no-error.
     if avail astmrp then do.
        if ii = 0 then do.
           s-mrp[1] = r-sum * 50.
           s-mrp[2] = r-sum * 50.
           s-mrp[3] = r-sum * 50.
           s-mrp[4] = r-sum * 50.
           leave.
        end.
        else do.
           s-mrp[ii] = r-sum * 50.
           ii = ii + 1.
        end.
     end.   
     else do.
        if ii <> 0 then do.
           message 'В справочнике МРП отсутствуют данные за ' ii 'квартал'
           v-year 'года.' .
           return.
        end.
        else ii = ii + 1.   
     end.
 
   end.
end.                  

put stream m-out skip
FirstLine( 1, 1 ) format 'x(107)' skip(1)
'                      '
'Данные о приобретении активов '  skip
'                      '
'за период ' v-dat1 '-' v-dat2 - 1 skip(1)
FirstLine( 2, 1 ) format 'x(107)' skip.
put stream m-out  
'---|--------|------------------------------|--------|------------|------------|------------|-----|-------|'  
 skip.
put stream m-out 
' N |   N    |         Название             |  Дата  |  Первонач. |  Начисл.   |  Остаточная|Кате-| Ставка|'  skip
' пп|карточки|                              |   рег. |  стоимость |  износ     |  стоимость |гория| износа|' skip.
put stream m-out
'---|--------|------------------------------|--------|------------|------------|------------|-----|-------|'
 skip.

ii = 0.

FOR each ast where ast.rdt ge v-dat1 
               and ast.rdt lt v-dat2
               and ast.icost > 0
               no-lock
               break  by ast.icost by ast.rdt by ast.ast.  
 usl = false.
 if v-kvart <> 0 then
     if ast.icost < s-mrp[v-kvart] then usl = true.
     else next.
 else do.
     if month(ast.rdt) ge 1 and month(ast.rdt) le 3 
        and ast.icost < s-mrp[1] then usl = true.
     else if month(ast.rdt) ge 4 and month(ast.rdt) le 6
                    and ast.icost < s-mrp[2] then usl  = true.
     else if month(ast.rdt) ge 7 and month(ast.rdt) le 9
                         and ast.icost < s-mrp[3] then usl = true.
     else  if month(ast.rdt) ge 10 
                         and ast.icost < s-mrp[4] then usl  = true.               end.    
 if usl = true then do.

 find last astatl where astatl.ast =ast.ast
                    and astatl.dt lt v-dat2
                    use-index astdt no-lock no-error.
 if not avail astatl  then 
    find first astatl where astatl.ast =ast.ast
         use-index astdt no-lock no-error.
      ii = ii + 1.
      put stream m-out
          ii format 'zz9' '|'
          ast.ast  format "x(8)" "|"
          ast.name  '|'
          ast.rdt '|'
          ast.icost format 'zzzzzzzz9.99' '|'
          astatl.nol format 'zzzzzzzz9.99' '|'
          astatl.atl format 'zzzzzzzz9.99' '|   '
          ast.cont format 'x(2)'  '|   '
          if length(trim(ast.ref)) = 1 
             then ' ' + trim(ast.ref) +  '  |'
             else       trim(ast.ref) +  '  |'       
          skip.
      s-icost = s-icost + ast.icost .
      s-nol   = s-nol   + astatl.nol.
      s-atl   = s-atl   + astatl.atl.
   end.    
end.
put stream m-out
'---|--------|------------------------------|--------|------------|------------|------------|-----|-------|'
 skip.
put stream m-out '   |        |'  'ВСЕГО ' space(24) '|        |'
      s-icost  format 'zzzzzzzz9.99' '|'
      s-nol    format 'zzzzzzzz9.99' '|'
      s-atl    format 'zzzzzzzz9.99' '|     |       |' skip.

output stream m-out close.

if not g-batch then do:
   pause 0 before-hide.
   run menu-xls( 'rpt.img' ).
   pause before-hide.
end.
                     
{functions-end.i}

