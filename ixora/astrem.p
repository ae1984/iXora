/* astrem.p
 * MODULE
        ОСНОВНЫЕ СРЕДСТВА
 * DESCRIPTION
	Формирование транзакций по текущему ремонту основных средств
	Input:  	vo - the code of operation from asttr table
	Output: 	0 - OK
			1 - ошибка

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
	KOVAL
 * CHANGES
	27/11/02 SASCO  :  Добавлена обработка списаний с АРП карточки склада
	18/08.2005 ten - message gl.des 
*/


def input parameter v-atrx as char.


def new shared var s-jh     like jh.jh.
def new shared var s-aah    as int.
def new shared var s-consol like jh.consol.
def new shared var s-force as log init false.
def new shared var s-line  as int.
def new shared var v-gl3 like trxlevgl.glr.
def new shared var v-gl4 like trxlevgl.glr.
def new shared var v-gl  like ast.gl.
def new shared var v-qty like ast.qty format "zzz9" init 0.         
def new shared var v-icost like ast.dam format "zzzzzz,zzz,zz9.99-".            
def new shared var vidop as char.
def new shared var v-fag as char format "x(3)".
def new shared var v-sum as dec format "zzz,zzz,zzz,zz9.99".
def new shared var v-nds as dec format "zzz,zzz,zzz,zz9.99".
def new shared var v-arp like arp.arp.
def new shared var v-arem as char extent 5 format "x(55)".
def new shared var v-cont like ast.cont format "x".
def new shared var v-ast  like ast.ast format "x(8)".
def new shared var kor-gl like jl.gl.
def new shared var arp-gl like jl.gl.
def new shared var kor-acc  like jl.acc.
def new shared var kor-acc1 like jl.acc.
def new shared var v-gl3d like gl.des.
def new shared var v-gl4d like gl.des.
def new shared var sumd1 as dec format "zzzzzz,zzz,zz9.99".
def new shared var sumc1 as dec format "zzzzzz,zzz,zz9.99".
def new shared var sumd3 as dec format "zzzzzz,zzz,zz9.99".
def new shared var sumc3 as dec format "zzzzzz,zzz,zz9.99".

def buffer xaaa for aaa.
def var atld  as dec format "zzzzzz,zzz,zz9.99" init 0.
def var atlc  as dec format "zzzzzz,zzz,zz9.99" init 0.
def var fondd as dec format "zzzzzz,zzz,zz9.99" init 0.
def var fondc as dec format "zzzzzz,zzz,zz9.99" init 0.
def var v-ast1  like ast.ast format "x(8)".
def var v-nol   like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-atl   like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-fond  like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-ydam4 like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-ycam4 like ast.dam format "zzzzzz,zzz,zz9.99-".
def var v-fagn  like fagn.naim.
def var kodcrc  like crc.code.
def var v-fond1  as dec       format "zzz,zzz,zzz,zz9.99".
def var v-gldes  as char.
def var v-gln    as char.
def var arp-des  as char.
def var v-gldes1 as char.
def var v-kdes   as char.
def var vln      as int.
def var otv      as log.
def var vdel     as cha initial "^" .
def var rdes     as cha .
def var rcode    as int .
def var vparam   as cha .
def var shcode   as cha .
def var arem     as char.
def var arem1    as char.
def var arem2    as char.
def var klud     as log .


{global.i}


form	"Nr.КАРТОЧКИ :" v-ast  "ГР.:" ast.fag view-as text v-fagn view-as text "  СЧЕТ :" ast.gl view-as text skip
	"НАЗВАНИЕ    :" ast.name  view-as text skip 
	"КОЛИЧЕСТВО  :" ast.qty view-as text format "zzz9" "ДАТА РЕГ. :" at 40 ast.rdt view-as text skip
	"БАЛАНС.СТОИМ:" v-icost[1] view-as text skip
	"ИЗНОС       :" v-nol[1] view-as text   skip
	"ОСТАТ.СТОИМ.:" v-atl[1] view-as text   skip
	"ПРИМЕЧАНИЕ  :" ast.rem  view-as text skip(1)
	"Введите параметры для создания транзакции по ремонту:" skip
	"Cум. ремонта:" v-sum    no-label " Сумма НДС:" v-nds     no-label skip
	"Счет гл.кн. :" v-gl     no-label "  Счет ARP:" v-arp     no-label skip
	"Назначение  :" v-arem[1] no-label skip
	v-arem[2] no-label skip
	v-arem[3] no-label skip
	v-arem[4] no-label 
	with frame ast row 2 overlay centered no-label title "   " + v-arem[1].

hide all.



find asttr where asttr.asttr=v-atrx no-lock no-error.
if avail asttr then v-arem[1]=asttr.atdes.

update v-ast validate(v-ast ne ""," ВВЕДИТЕ КАРТОЧКУ ") with frame ast.
v-ast1=v-ast.

find ast where ast.ast=v-ast no-lock no-error.
if not avail ast            then do: message "КАРТОЧКИ НЕТ ". pause 5. return. end.
if ast.dam[1] - ast.cam[1] eq 0 then do: message "ОСТАТОК  0 ".   pause 5. return. end.  

assign 	v-ast=ast.ast 
	v-gl =ast.gl.
 
find gl where gl.gl=v-gl no-lock.
if avail gl then do:
on entry of v-gl  do:
                message gl.des.


end.
end.
on leave of v-gl do:
hide  message.
end.


v-gln=gl.des.

find first trxlevgl where trxlevgl.gl=ast.gl and trxlevgl.lev=3 no-lock no-error.
if available trxlevgl then v-gl3 = trxlevgl.glr. 
                      else v-gl3=?.   

find gl where gl.gl eq v-gl3 no-lock no-error.
if available gl then v-gl3d=gl.des. 
                else v-gl3d="".

find first trxlevgl where trxlevgl.gl=ast.gl and trxlevgl.lev=4 no-lock no-error.
if available trxlevgl then v-gl4 = trxlevgl.glr.
                      else v-gl4 = ?.

find gl where gl.gl eq v-gl4 no-lock no-error.
if available  gl then v-gl4d=gl.des.
                 else v-gl4d="".

find first crc where crc.crc=ast.crc no-lock.
assign	kodcrc=crc.code
	v-qty=0
	v-fag=ast.fag.

find fagn where fagn.fag=v-fag no-lock.
v-fagn    =fagn.naim.
v-icost[1]=ast.dam[1] - ast.cam[1].
v-nol[1]  =ast.cam[3] - ast.dam[3].
v-fond[1] =ast.cam[4] - ast.dam[4].
v-atl[1]  =v-icost[1] - v-nol[1].
v-cont    =ast.cont.  
v-ydam4[1]=ast.ydam[4].
v-ycam4[1]=ast.ycam[4].

displ v-ast ast.fag v-fagn ast.gl ast.qty  ast.rdt ast.name 
      v-atl[1] v-icost[1] v-nol[1] ast.rem with frame ast.

find asttr where asttr.asttr  = v-atrx no-lock no-error.
if avail asttr then v-arem[1] = asttr.atdes.


/* SASCO - ДЛЯ СПИСАНИЯ СО СКЛАДА ---->*/
define temp-table wcho
       field des like skladb.des label "DES" column-label "НАИМЕНОВАНИЕ"
       field amt like skladc.amt label "AMT" column-label "КОЛИЧЕСТВО"
       field cost like skladc.cost label "KZT" column-label "ЦЕНА"
       field dpr like skladc.dpr label "ДАТАПР" column-label "ДАТАПР"
       index iid dpr.
define var v-sid like skladb.sid.
define var v-pid like skladb.pid.
define var v-sdes as char.
define var v-pdes as char.
define var v-dpr as date.
define var v-amt as int.
define var v-cost as decimal.
define var sk_cost as decimal init 0.
define var sk_amt as int init 0.
define var sk_total as decimal init ?.
/* <-----------------------------------*/


ma:
repeat on error undo,retry on endkey undo,return:
 
 update v-sum v-gl v-arp v-nds v-arem[1] v-arem[2] v-arem[3] v-arem[4] with frame ast.

   find arp where arp.arp eq v-arp no-lock no-error.
   if not available arp  then do: bell. {mesg.i 2203}. undo,retry. end.
   if arp.crc <> 1       then do: bell. {mesg.i 9813}. undo,next.  end.

   /* sasco - for SKLAD`s arp */
   if v-arp = "000940601" then do:

      {ast-sklad-sel.i}

   end.

   if v-sum<=0           then do: bell. message "Не заполнена сумма ремонта". undo,retry. end.
   if trim(v-arem[1])="" then do: bell. message "Заполните назначение транзакции". undo,retry. end.
   if v-gl=0             then do: bell. message "Не заполнен счет главной книги". undo,retry. end.
   if trim(v-arp)=""     then do: bell. message "Не заполнен счет ARP". undo,retry. end.

   arp-gl =arp.gl.
   arp-des=arp.des.

   find gl where gl.gl=arp-gl no-lock no-error.
   if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.

   v-gldes1=gl.des. 
   leave.
end. /* repeat ma */

otv=true.

repeat on endkey undo,retry:
 message " ОПЕРАЦИЮ ВЫПОЛНИТЬ ? " UPDATE otv format "да/нет".
 if not otv then return.
 leave.
end.

klud=true.

Do transaction:

   arem=trim(trim(v-arem[1]) + " " + trim(v-arem[2]) + " " + trim(v-arem[3]) + " " + trim(v-arem[4])).

   shcode="VNB0009".
   vparam=string(v-nds)         + vdel +
          v-arp                 + vdel +
          arem                  + vdel +
          string(v-sum)         + vdel +
          string(v-gl,"999999") + vdel +
          arem.

   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes, input-output s-jh).
   if rcode > 0 or s-jh = 0  then
   do:
         Message " Error: " + string(rcode) + ":" + rdes.
         pause.
         undo,leave.
   end.
   else 
   do:

      /* sasco - for SKLAD */
      {ast-sklad-hist.i}

      find ast where ast.ast=v-ast exclusive-lock.
               ast.ofc=g-ofc.
               ast.updt=g-today.

      create astjln.
      assign
      astjln.ajh = s-jh
      astjln.aln = 1
      astjln.awho = g-ofc
      astjln.ajdt = g-today
      astjln.arem[1]=substring(v-arem[1],1,55)
      astjln.arem[2]=substring(v-arem[2],1,55)
      astjln.arem[3]=substring(v-arem[3],1,55)
      astjln.arem[4]=substring(v-arem[4],1,55)
      astjln.aamt = v-sum /* Сумма без НДС */
      astjln.cam  = 0
      astjln.dam  = v-sum   
      astjln.adc  = "D"
      astjln.agl  = ast.gl
      astjln.aqty = v-qty
      astjln.aast = v-ast
      astjln.afag = v-fag
      astjln.atrx = v-atrx
      astjln.ak   = v-cont
      astjln.icost=0
      astjln.korgl=v-gl
      astjln.koracc= kor-acc
      astjln.vop   = 0
      astjln.apriz = ""
      astjln.d[1]  = v-sum.

      /* Штампует транзакцию
      find first jh where jh.jh = s-jh no-error.
      if available jh and jh.sts = 5 then do:
       for each jl of jh:
          assign
          jl.sts = 6
          jl.teller = g-ofc.
       end.
       jh.sts = 6.
      end.   
      run jl-stmp.*/

      run trxsts (input s-jh, input 6, output rcode, output rdes).
      if rcode ne 0 then do:
            message " Ошибка rcode = " string(rcode) ":" rdes  " " s-jh.
            pause.
            undo,return.  
      end.
      else message "Транзакция сделана" skip  " N=" s-jh view-as alert-box. 

      run x-jlvouR.

      pause 0 .
      klud=false.
   end.
 end.
 
release ast.
release astatl.
release astjln.

if rcode = 0 and not klud then repeat:
 otv=false.

 message " Повторить печать?  " UPDATE otv format "да/нет". 

 if otv then do: 
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvouR.  
    pause 0.
 end.
 else leave.

end.

