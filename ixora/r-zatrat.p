/* r-zatrat.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        codsdat.p
 * MENU
        8-7-3-12
 * AUTHOR
        04/02/06 nataly
 * CHANGES
        22.06.2006 nataly был довавлена обработка склада, Прилож 12,13,14.
*/

def var v-sum as decimal.
def var col1 as integer.
def var coldep as integer.

define  shared var g-today  as date.

{zatratdef.i "new"}

def var v-dam as decimal.
def var v-cam as decimal.
def var totcam as decimal.
def var totdam as decimal.
define  var v-des like cods.des label "Наименование".
define  var v-name like cods.des label "Наименование".


def temp-table t-gl      /*остатки по счетам амортизации*/
     field gl like gl.gl
     field dep as char
     field gl1 like gl.gl
     field mon as decimal
     field col1 as integer
     field ost as decimal.

def new shared temp-table v-deps   /*таблица департаментов*/
      field dep as char
      field depname as char
        index dep is primary   dep .

def buffer b-codfr for codfr.
def button  btn1  label "Сокр.форма (прил14)".
def button  btn2  label "Расш.форма (прил13)".
def button  btn3  label "Приложения 1-12,15-35".
def button  btn4  label "Выход".
def  var prz as integer.
def var i as integer init 1.
def frame   frame1
   skip(1) btn1 btn2 btn3 btn4 with centered title "Выберете вариант отчета:" row 5 .

/*run zatrat0.*/
/*
for each codfr where codfr.codfr = 'sproftcn' and codfr.code = codfr.code no-lock.
 if name[3] = ""  then do:
  find b-codfr where codfr.codfr = 'sdep' and  b-codfr.code = trim(codfr.name[4]) no-lock no-error.
  if avail b-codfr then message 'yes'  b-codfr.code  b-codfr.name[3]. 
 end. 
end. 
message '33'.
  */
do transaction:
/*       v-attn validate(can-find(codfr where codfr = "sproftcn" and codfr.code = v-attn) ,
                       "неверно задан департамент ")  with frame am.*/

def frame opt
           v-dep label 'ЗАДАЙТЕ КОД ДЕПАРТАМЕНТА (F2-выбор)'  
            validate(can-find(codfr where codfr.codfr = "sdep" and codfr.code = v-dep ) ,  "Неверно задан департамент ") skip
            v-des view-as text skip
              with row 8 centered  side-label.
on help of v-dep in frame opt do: 
                                   run help-dep('000').
                                   v-dep:screen-value = return-value.
                                   v-dep = v-dep:screen-value.
                                end.

  on choose of btn1,btn2,btn3,btn4 do:
    if self:label = "Сокр.форма (прил14)" then prz = 1.
    else
    if self:label = "Расш.форма (прил13)" then prz = 2.
    else
    if self:label = "Приложения 1-12,15-35" then prz = 3.
       else prz = 4.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3, btn4.
     if prz = 3 then do: 
       update v-pril label 'ВЫБЕРЕТЕ ПРИЛОЖЕНИЕ (F2-выбор)'
                validate(can-find(codfr where codfr.codfr = 'spril' and codfr.code = v-pril no-lock), 'Неверно выбрано приложение!')
         v-name view-as text skip
       with row 5 centered side-label frame opt2.

      find codfr where codfr.codfr = 'spril' and codfr.code = v-pril:screen-value no-lock no-error.
      if avail codfr then v-name = codfr.name[1]. else v-name = "".
      displ  v-name with frame opt2.
    end.
    if prz = 4 then return.
 hide  frame frame1.
 pause 0.
if prz = 1 then do: v-pril =  '14'. v-name = 'Приложение 14'.  end.
if prz = 2 then  do: v-pril = '13'.  v-name = 'Приложение 13'.  end.

if integer(v-pril) < 21 or (integer(v-pril) > 25 and integer(v-pril) < 35)   then do:
     update v-dep 
              with row 8 centered  side-label frame opt. 

    find codfr where codfr.codfr = 'sdep' and codfr.code = v-dep:screen-value no-lock no-error.
    if avail codfr then v-des = codfr.name[1]. else v-des = "".
   displ  v-des with frame opt.
 end.

find codfr where codfr.codfr = 'sproftcn' and codfr.name[4] = v-dep:screen-value no-lock no-error.
if avail codfr then depzl = codfr.name[3].
v-depname = v-des.
 
    update m1 label 'ЗАДАЙТЕ ПЕРИОД С' 
             validate(m1 <= 12,   "Дата не может быть больше текущей даты..... ")
            help "Введите начальную дату."
            m2 label 'ПО'
             validate(m2 <= 12,   "Дата не может быть больше текущей даты..... ")
            help "Введите конечную дату."
            y1 label 'мес.' 'года '
            with frame opt overlay centered side-labels row 8 1 down.
  if m2 < m1 then 
   do:
     message 'Конечная дата не может быть меньше начальной!' view-as alert-box.
     undo,retry.
   end.
end.
 hide frame opt.
v-attn = v-dep.
/*v-dep = v-attn.*/


 display '   ЖДИТЕ...   '  with row 5 frame ww centered .




/*ищем профит-центр по коду деп-та из Зарплаты*/
/*find first ofc-tn where ofc-tn.dep = v-attn no-lock no-error. 
if avail ofc-tn then v-attn =  ofc-tn.profitcn. else v-attn = "".*/
/*find first codfr where codfr.codfr = 'sproftcn' and codfr.name[4] = v-attn no-lock no-error.
if avail codfr then v-attn = codfr.code. else v-attn = "".
if avail codfr then v-doxras = codfr.name[4]. else v-doxras = "".
  */
v-doxras = v-dep.
/*ОС + коды доходов, расходов*/
{r-brfilial2.i &proc = "zatratdat(comm.txb.bank,output v-bank, output p-code)" } 
 {comm-txb.i}
seltxb = comm-cod().
 {get-dep.i}

/*Расходы за ЗП*/
seltxb = p-code.
run  zatrat2. /*zatrat31*/
/*for each temp.
    message temp.nalog temp.tn temp.dep. end. 
  */

output stream vcrpt to 'zatrat.html'. 
{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}


run zatrati.
 /*----------------*/


