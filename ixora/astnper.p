/* astnper.p
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

{global.i}
def  shared var s-astnal as int.
define shared var v-god like astnal.god.
define var v-datn like astjln.ajdt.
define var v-datk like astjln.ajdt.
define var otv2 as logic. 
def var v-grup like astnal.sieg format "zzzzzz,zzz,zz9.99-".

def temp-table    p   field god like astnal.god 
                      field ast like astnal.ast
                      field data like astjln.ajdt 
                      field atrx like astjln.atrx
                      field grup  like astnal.grup
                      field sper like astnal.sper format "zzzzzz,zzz,zz9.99-"
                      field sieg like astnal.sieg format "zzzzzz,zzz,zz9.99-"
                      field sizs like astnal.sizs format "zzzzzz,zzz,zz9.99-"
                      field skor like astnal.sizs format "zzzzzz,zzz,zz9.99-"
                      index grup is primary grup ast.

otv2 = false.
v-datn =date(1,1,v-god). 
v-datk =date(12,31,v-god). 
hide all. pause 0. 

  update "Cбор информацции за период с " 
              v-datn validate(year(v-datn) = v-god , "Проверьте год") 
           " до " v-datk validate(year(v-datk) = v-god , "Проверьте год") 
  
      WITH FRAME astd no-label row 7 centered . 
  
       
 For each astjln where astjln.ajdt > v-datn - 1 and astjln.ajdt < v-datk + 1 
                use-index dtajh no-lock,
               each ast where ast.ast = astjln.aast  no-lock :
 
        displ " ЖДИТЕ ИДЕТ CБОР ИНФОРМАЦИИ"  astjln.ajdt astjln.aast
               with frame s row 9 centered no-labels.
         pause 0.
         create p.
         p.god = v-god.
         p.ast = ast.ast.
         p.grup = ast.cont.
         p.data =astjln.ajdt. 
         p.atrx =astjln.atrx. 
       if substring(astjln.atrx,1,1) = "p" then   
         p.sper = p.sper + astjln.d[1] - astjln.c[1] .
       else if substring(astjln.atrx,1,1) = "1" then 
         p.sieg = p.sieg + astjln.d[1] - astjln.c[1] . 
       else if substring(astjln.atrx,1,1) = "6" then 
         p.sizs = p.sizs + astjln.c[1] - astjln.d[1] . 
       else 
         p.skor = p.skor + astjln.d[1] - astjln.c[1] . 
 
      if p.sper = 0 and p.sieg =0 and p.sizs = 0 and p.skor =0 then
      delete p. 
 end.

 


find first p where true no-lock no-error.
if not avail p then do: Message "ДАННЫХ ДЛЯ ПЕРЕНОСА НЕТ ". pause 10. return. end. 
 /*  Atskaites druka*/
{image1.i rpt.img}
{image2.i}
 put chr(27) + chr(15) format "xx"  .
{report1.i 131}
vtitle= " Информация по операциям по основным средствам  в разрезе групп налог.амортиз.за " + string (v-god). 
{report2.i 131 
"'Nr.карточ.Дата операц.   Прирост ст-ти  Стоим.поступ.ОС   Koppeктир.стоим. Стоим.выбывших ОС Код опер.     Название       '  skip 
  fill('=',131) format 'x(131)' skip "}

 For each p break by p.grup by p.data by p.ast :
                     
    accumulate p.sper (total by p.grup). 
    accumulate p.skor (total by p.grup).
    accumulate p.sieg (total by p.grup).
    accumulate p.sizs (total by p.grup).
   
   if first-of(p.grup)  then
        Put   " Группа " p.grup skip. 

    find ast where ast.ast = p.ast no-lock no-error. 
    
    PUT p.ast 
        p.data format "99/99/9999" 
        p.sper     
        p.sieg  
        p.skor
        p.sizs
        p.atrx at 96.
    if avail ast then PUT " " ast.name  format "x(30)".
    PUT  skip.
 

   if last-of(p.grup) then do: 
     Put fill('-',131) format 'x(131)' skip.

    PUT skip(1) "Всего по группе:".
    Put  p.grup format "x(2)"    
     accum total by p.grup p.sper format "zzzzzz,zzz,zz9.99-"
     accum total by p.grup p.sieg format "zzzzzz,zzz,zz9.99-"
     accum total by p.grup p.skor format "zzzzzz,zzz,zz9.99-"
     accum total by p.grup p.sizs format "zzzzzz,zzz,zz9.99-" skip.

    Put fill('-',131) format 'x(131)' skip.
     
   end.
   
 End.
   Put "   ВСЕГО          "
     accum total p.sper format "zzzzzz,zzz,zz9.99-" 
     accum total p.sieg format "zzzzzz,zzz,zz9.99-"
     accum total p.skor format "zzzzzz,zzz,zz9.99-"
     accum total p.sizs format "zzzzzz,zzz,zz9.99-" skip.
   Put  fill('=',131) format 'x(131)' skip(1).


{report3.i}
{image3.i}

hide all.

message "ПЕРЕНЕСТИ ИНФОРМАЦИЮ ИЗ ФАЙЛА ОПЕРАЦИЙ? (Да/Нет)" 
                    update otv2 format "Да/Нет". 

if otv2= false then do: 
   hide all. pause 0.
   return.
end.

for each astnal where astnal.god = v-god :
    astnal.sper = 0.  
    astnal.sieg = 0.
    astnal.sizs = 0. 
    astnal.damn2[1] =0.
end. 

 
 For each p use-index grup break by p.grup by p.ast:
     
       displ "Номер карточки" p.ast  with frame a row 7 centered no-labels
        title " ЖДИТЕ ИДЕТ ПЕРЕНОС ИНФОРМАЦИИ ИЗ ФАЙЛА ОПЕРАЦИЙ ".
        pause 0.


    Find first astnal where astnal.god=v-god and astnal.grup = p.grup
     exclusive-lock no-error.
    if not available astnal then do:
        create astnal.
        astnal.god  = p.god.
        astnal.grup = p.grup.
    end.
    else if astnal.ast ne "" and  astnal.ast ne p.ast then do: 
             
          find first astnal where astnal.god = p.god and   
                                  astnal.grup = p.grup and
                                  astnal.ast = p.ast exclusive-lock no-error.  
             
           if not available astnal then do:
         
             create astnal.
             astnal.god  = p.god.
             astnal.grup = p.grup. 
             astnal.ast  = p.ast.  
   
          end.
    end.

    
     astnal.sper = astnal.sper + p.sper .
     astnal.sieg = astnal.sieg + p.sieg . 
     astnal.sizs = astnal.sizs + p.sizs . 
     astnal.damn2[1] = astnal.damn2[1] + p.skor . 
 
    {astnal.i 0}
 end.
 
hide all. pause 0. 
 
 
 
                          
