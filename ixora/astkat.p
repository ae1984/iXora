/* astkat.p
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

def var v-ast like ast.ast format "x(8)".
def var v-nol like ast.icost format "zzz,zzz,zz9.99-".
def var v-sum as dec format "zzz,zzz,zz9.99-".
def var v-cont like ast.cont format "x".
def var v-fagn as char format "x(20)".
def var v-ref  as decim format "zz9" init 0.
def var v-addrn as char format "x(25)" init " ".
def var v-attnn as char format "x(25)" init " ".
def var v-atrx as char.
def var v-arem as char extent 5 format "x(55)".
def var kor-cont like ast.cont format "x".     
def var kor-ref  as decim format "zz9" init 0.
def var v-god as int format "9999".
def var otv as log.
define variable vcha1 as character format "x(50)".
define variable vcha2 as character format "x(50)".
define variable vcha3 as character format "x(50)".
{global.i}
form
   "   Nr. AST карточки для изменения категории "  v-ast   skip
 with frame ast1 overlay centered no-labels row 7 .

form
    "ГРУППА     :" ast.fag  v-fagn "  СЧЕТ  :" ast.gl skip
    "Nr КАРТОЧКИ:" v-ast "   ИНВ.Nr.:" ast.addr[2] skip
    "НАЗВАНИЕ :" ast.name "КОЛ-ВО:" ast.qty format "zzz9-" " РЕГ.ДАТА  :" ast.rdt skip
    "ПРИМЕЧ.  :" ast.rem skip
    "ПЕРВОН.СТОИМОСТЬ" ast.icost format "zzz,zzz,zz9.99-" skip
                          
    "ОСТАТ.СТОИМОСТЬ :" v-sum   "   Nolietojums:"   v-nol  skip        
    "-------------------------------------------------------------------------" skip
    "СРОК ИЗНОСА (кол_во лет ):" ast.noy  "  КОД ГР.ИЗНОСА :" ast.ser skip(1)
    "ОТВЕТСТВ.ЛИЦО:" ast.addr[1] format "x(3)" " " v-addrn skip
    "МЕСТО РАСПОЛ.:" ast.attn format "x(3)" " " v-attnn skip(1) 
  "--------------- Данные для расчета налога  -----------------------------" SKIP
    "   КАТЕГОРИЯ  :" v-cont  "     СТАВКА ИЗНОСА:" v-ref  "x 2 % " skip
    "   НА " ast.ddt "ОСТ.СТОИМ.ДЛЯ НАЛОГ.:" at 17 ast.crline format "zzz,zzz,zz9.99-"skip
  with frame astk row 2 overlay centered no-label
                 title " ИЗМЕНЕНИЕ НАЛОГОВОЙ КАТЕГОРИИ  ". 
form 
   " ИЗМЕНИТЬ           С           НА    " skip
    "категория :"  v-cont to 23  kor-cont to 35 "   " skip 
    "ставка    :"  v-ref  to 23  kor-ref to 35 "   " skip(1) 
    " С  " v-god  "  финанс.года  " 
      with frame op1 overlay centered no-labels row 13.

repeat on endkey undo,return on error undo,retry:
update v-ast validate(v-ast ne ""," ВВЕДИТЕ НОМ.КАРТОЧКИ     " )
    with frame ast1.
 find ast where ast.ast=v-ast no-lock no-error.
  if not avail ast then do: message "КАРТОЧКИ НЕТ ". pause 5. return. end.
  if ast.dam[1] - cam[1] eq 0 then do: 
       otv=false.
       message " ОСТАТОК 0. ИЗМЕНИТЬ КАТЕГОРИЮ   ? " UPDATE otv format "да/нет". 
        if  not otv then return. 
  end.  

 find fagn where fagn.fag=ast.fag no-lock.
 kor-cont=fagn.cont.
 kor-ref=integer(fagn.ref).
 v-fagn=fagn.naim.
 v-sum= ast.dam[1] - ast.cam[1].
 v-nol= ast.icost - v-sum.
 find astotv where astotv.kotv=ast.addr[1] and astotv.priz="A" no-lock no-error.
 if avail astotv then v-addrn=astotv.otvp. 

 find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.
 if avail codfr then  v-attnn = codfr.name[1].
 v-cont=ast.cont.
 v-ref=integer(ast.ref).

 displ ast.fag  v-fagn  ast.gl  v-ast  ast.addr[2] ast.name  ast.qty  ast.rdt 
       ast.mfc  ast.rem ast.icost  v-sum v-nol          
       ast.noy  ast.ser  ast.addr[1] v-addrn ast.attn v-attnn  
       v-cont   v-ref  ast.ddt  ast.crline 
    with frame astk.

  displ v-cont v-ref kor-cont kor-ref  with frame op1.

do on endkey undo,return on error undo,retry:
 
 update kor-cont with frame op1.

 find first fagn where fagn.cont=kor-cont no-lock no-error.
  if avail fagn then  kor-ref=integer(fagn.ref).
                else  if kor-cont<>"" then undo,retry.
  displ kor-ref with frame op1.
  v-god=year(g-today).
  update v-god validate(v-god>=year(ast.rdt) and v-god<=year(g-today),
                                " ПРОВЕРЬТЕ ГОД   ")
    with frame op1. 
end.
  if kor-ref=v-ref and kor-cont=v-cont then next.

LEAVE.
end. 

  otv=false.
   message "  ИЗМЕНИТЬ КАТЕГОРИЮ ?  " UPDATE otv format "да/нет".
   
        if  not otv then return. 
do transaction:
         find ast where ast.ast=v-ast.
                ast.cont=kor-cont.
                ast.ref=string(kor-ref).
                ast.ofc=g-ofc.
                ast.updt=g-today.
 
         for each astjln where astjln.ajdt>=date(1,1,v-god)
                     and astjln.atrx ne "0"  and astjln.aast=v-ast:
                astjln.ak=kor-cont.
         end.                     
         create astjln. astjln.aast=v-ast.
                        astjln.ajh =0.
                        astjln.atrx="0".
                        astjln.aln = 0.
                        astjln.arem[1]="Изм.катег.(с  " + string(v-god ) +
                             ")с  кат." + v-cont + " ставка" + string(v-ref) + "%".
                                    
                        astjln.arem[2]= " - на кат. " + kor-cont + " став." + string(kor-ref) + "%".
                        astjln.awho = g-ofc.
                        astjln.ajdt = g-today.
                        astjln.ak= v-cont + "-" + kor-cont.
                        astjln.apriz="K".
                        astjln.kpriz=string(v-god,"9999").
                        astjln.crline=ast.crline.
/*message " Vauўera dr­k–Ѕanai iesledzёt printeru ". pause 20.
*/

output to vou.img page-size 0.
put skip(3)
"==============================================================================" skip
 " ИЗМЕНЕНИЕ КАТЕГОРИИ ОСН.СРЕДСТВА  " at 23  skip .
put g-today at 8  " " string(time,"HH:MM") 
"*" at 64 g-ofc skip.                                               
put
"----------------------------------------------------------------------------"
skip.

find ast where ast.ast eq v-ast no-lock.
find gl where gl.gl eq ast.gl no-lock.
put gl.gl at 8 "  " gl.des skip(1)  
v-ast at 8 ast.name at 22 skip(1)
"-----------------------------------------------------------------------------" 
skip(1).
put astjln.arem[1] at 8 skip. 
put astjln.arem[2] at 8 skip(1) 
"==============================================================================="
skip(20).
output close.
unix silent prit -t vou.img.

message "ОПЕРАЦИЯ ВЫПОЛНЕНА". 
bell.
otv=true.
end.

if not otv then return. 
repeat:
    otv=false.
    message "  Повторить печать?  " UPDATE otv format "да/нет". 
    if otv then unix silent prit -t vou.img.
           else return.
end.
  
