/* astpv.p
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
            24/05/2013 Luiza - ТЗ 1842 закрепление ОС за сотрудником

*/

/*parv1 p–rvietoЅana */
/* 23.04.2003 Sasco - история перемещений */

def new shared var v-ast like ast.ast format "x(8)".
def new shared var v-gl  like ast.gl.
def var v-name like ast.name.
def var v-mfc like ast.mfc format "x(30)".
def var v-rem like ast.rem format "x(60)".
def new shared var v-qty like ast.qty format "zzz9" init 1.
def var v-fag as char format "x(3)".
def var v-ser like ast.ser.
def var v-noy like ast.noy init 0.
def var v-rdt like ast.rdt.
def var v-icost like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-nol   like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-fond  like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-atl as dec           format "zzzzzz,zzz,zz9.99".
def var v-icost1 like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-nol1   like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-fond1  like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-atl1 as dec           format "zzzzzz,zzz,zz9.99".
def var v-nolp like ast.icost format "zzz,zzz,zz9.99".
def var v-salv like ast.salv init 0.
def var v-ssum as dec format "zzz,zzz,zz9.99".
def var v-cont like ast.cont format "x".
def var v-ref  as decim format "zz9" init 0.
def var v-ddt  as date.
def var v-crline like ast.crline format "zzzzzzz9.99-" init 0.
def var v-ydam5 like ast.crline format "zzzzzzz9.99-" init 0.
def var v-fagn like fagn.naim.
def var v-addr as char format "x(3)".
def var v-attn as char format "x(3)".
def var v-addrn as char format "x(25)" init " ".
def var v-attnn as char format "x(25)" init " ".
def var v-ldd like ast.ldd.
def var v-kdes as char.
def var vgln1 like gl.gl init 0.
def var vgln2 like gl.gl init 0.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(55)".
def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .
def var arem as char.
def  var vop as int.
def  var kor-gl like jl.gl.
def  var kor-acc like jl.acc.
def  var kor-cont like ast.cont format "x".
def var kor-ref  as decim format "zz9" init 0.
def var v-addr2 as char format "x(10)".
def var otv as log.
def var klud as log init true.
def new shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-force as log init false.
def new shared var s-consol like jh.consol.
def new shared var s-line as int.

def var v-ajh like jh.jh.
def var v-ajdt like astjln.ajdt.
def var fag like fagn.fag format "x(3)".
def var old-invnr as char.
def var old-dep as char.

{global.i}



form
    "ГРУППА:" fag  " Nr.КАРТ." kor-acc  "СЧЕТ :" kor-gl  v-fagn   skip
    "КОЛ-ВО:" v-qty "НАЗВАНИЕ :" v-name format 'x(25)' "ИНВ.N." v-addr2 format 'x(20)' skip
    "БАЛАНС.СТОИМ. :" v-icost "      ИЗНОС    :" at 35  v-nol skip
    "ОСТАТ.СТОИМ.  :" v-atl   "ФОНД ПЕРЕОЦЕНКИ:" at 35  v-fond  skip
    "--------------- Данные для расчета налога  -------------------------" SKIP
    "КАТЕГ." v-cont "СТАВ.ИЗН.:" v-ref
/*    "на" v-ddt  "НАЛ.ОСТ.СТОИМ" at 45  v-crline skip
                "тек.года изм." at 45  v-ydam5*/  skip
    "ПРИМЕЧАНИЕ :" v-rem skip
    "СРОК ИЗНОСА (кол-во лет ):" v-noy  "  КОД ГР.ИЗНОСА :" v-ser skip
    "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
    "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip
    "ОПИСАНИЕ  " v-arem[1] skip
    "ОПЕРАЦИИ :" v-arem[2] skip
                 v-arem[3] at 12 skip
 with frame kor overlay centered no-labels row 6
        title "  НОВАЯ КАРТОЧКА " .

form
   "ПЕРЕМЕСТИТЬ С карточки "  v-ast   skip
 with frame ast1 overlay centered no-labels row 7 .

form
    "НАЗВАНИЕ :" ast.name "КОЛ-ВО:" ast.qty format "zzz9" "ДАТА РЕГ. :" ast.rdt skip
    "БАЛАНС.СТОИМ. :" v-icost1 "      ИЗНОС    :" at 35  v-nol1 skip
    "ОСТАТ.СТОИМ.  :" v-atl1   "ФОНД ПЕРЕОЦЕНКИ:" at 35  v-fond1  skip
    "ПРИМЕЧАНИЕ:" v-rem skip
    "---------------------------------------------------------------------------" skip
    "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
    "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip(1)
    "Inv.Nr.       " ast.addr[2] skip(1)
  /*  "ОСТАТ.НАЛ.СТОИМ.НА" ast.ddt[1]  v-crline " тек.года изм." v-ydam5 */
  with frame ast row 2 overlay centered no-label
                 title "С КАРТ.Nr." + v-ast + " гр." + v-fag + " счет " + string(v-gl)
                 + "/ПЕРЕМЕЩЕНИЕ ОС".

form
   "ПЕРЕМЕСТИТЬ     С                    НА    " skip
    "Nr.Карт."    v-ast  to 28  kor-acc  to 52 skip
    "Счет "       v-gl   to 28  kor-gl   to 50 skip
    "Категория "  v-cont to 28  kor-cont to 50 skip
    " С перв.стоим" v-icost  "  износом      " v-nol skip
    " С ост.стоим." v-atl    "  фонд переоценки " v-fond skip(1)
       with frame op overlay centered no-labels row 11.
hide all.


 update v-ast validate(v-ast ne ""," ВВЕДИТЕ НОМЕР КАРТОЧКИ " )
    with frame ast1.
 find ast where ast.ast = v-ast no-lock no-error.
  if not avail ast then do: message "КАРТОЧКИ НЕТ ". pause 5. return. end.
  if ast.dam[1] - cam[1] eq 0 then do: message "ОСТАТОК 0 ". pause 5. return. end.
  if ast.own <> "" then do: message "ОС не откреплено от сотрудника ". pause 5. return. end.

  if year(ast.rdt) = year(g-today) and ast.qty = ast.meth then do:
   message "ДАТА РЕГ.  " + string(ast.rdt) + " . ВЫПОЛНИТЕ СТОРНО     ".
  end.
 v-ast=ast.ast.
 v-gl=ast.gl.
 v-fag=ast.fag.
 find fagn where fagn.fag=v-fag no-lock.
 v-fagn=fagn.naim.
 v-rdt=ast.rdt.
 v-qty=ast.qty.
 v-icost1= ast.dam[1] - ast.cam[1].
 v-nol1= ast.cam[3] - ast.dam[3].
 v-atl1= v-icost1 - v-nol1.
 v-fond1= ast.cam[4] - ast.dam[4].
 v-addr=ast.addr[1].
 find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
 if avail astotv then v-addrn=astotv.otvp.
 v-attn=ast.attn.
 find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
 if avail codfr then  v-attnn = codfr.name[1].
 v-cont=ast.cont.
 v-ref=integer(ast.ref).
 v-name=ast.name. v-mfc=ast.mfc. v-rem=ast.rem.
 v-crline=ast.crline.
 v-ydam5=ast.ydam[5].
 v-ddt=ast.ddt[1].
 v-ldd=ast.ldd.
 old-invnr = ast.addr[2].
 old-dep = ast.attn.
 displ  /* v-fag v-fagn */ ast.qty  ast.rdt ast.name v-mfc v-rem ast.addr[2]
        v-addr v-addrn v-attn v-attnn v-atl1 v-icost1  v-nol1 v-fond1
        /*ast.ddt[1]  v-crline v-ydam5 */
         with frame ast.

pause.

ma:
repeat on error undo,retry on endkey undo,return:
   update fag validate(can-find(fagn where fagn.fag = fag)," ГРУППЫ НЕТ С СЛОВАРЕ, <F2> - СПИСОК" )
         with frame kor.
   find fagn where fagn.fag=fag exclusive-lock no-error.

      kor-acc=fag + string(fagn.pednr, "99999").
      fagn.pednr= fagn.pednr + 1.
      find ast where ast.ast=kor-acc no-lock no-error.
       if avail ast then do: pause 1. release fagn. next. end.

    kor-gl=fagn.gl. v-fagn=fagn.naim.
    v-ser=fagn.ser.
    kor-cont=fagn.cont.
    v-noy =fagn.noy.
    kor-ref=integer(fagn.ref).

   release fagn.
   otv=false.
   find ast where ast.ast=v-ast no-lock no-error.

   displ kor-gl kor-acc v-fagn v-name v-rem v-noy v-ser v-addr v-addrn
         v-attn v-attnn v-cont v-ref /*v-ddt*/
    with frame kor.   pause 0.
m1:

do on error undo,retry on endkey undo,next:

   update v-qty validate(v-qty >0 and v-qty <= ast.qty , " КОЛ-ВО   <=" + string(ast.qty))
         with frame kor.
   v-icost = round(v-icost1 / ast.qty * v-qty,2).
   v-nol = round(v-nol1 / ast.qty * v-qty ,2).
   v-atl = v-icost - v-nol.
   v-fond = round(v-fond1 / ast.qty * v-qty ,2).
   /*. if v-atl=v-atl1 and v-qty<>ast.qty then undo,retry. .*/
   if v-fag=fag and v-qty=ast.qty and kor-cont=v-cont then do:
     message "ПРОВЕРЬТЕ ГРУППУ или КОЛ-ВО". undo,retry.
   end.
   if v-qty=ast.qty then v-addr2=ast.addr[2].
                    else v-addr2=kor-acc.
   disp v-atl v-nol v-icost v-fond v-addr2  with frame kor. pause 0.
   update  v-name  v-addr2 with frame kor.
 do on error undo,retry /*on endkey undo,next*/ :
  update v-icost validate(v-icost >0 and v-icost <= v-icost1,
                          " ПЕРВ.СТОИМОСТЬ<= " + string(v-icost1))
         v-nol validate(v-nol >=0 and v-nol <= v-nol1,">0 un <=  "+ string(v-nol1))
               with frame kor.
   v-atl=v-icost - v-nol.
   displ v-atl with frame kor.
  update v-fond validate(v-fond >=0 and v-fond <= v-fond1,
                          " фонд <= " + string(v-fond1))
               with frame kor.

  if v-qty=ast.qty and (v-icost<>v-icost1 or v-nol<>v-nol1 or v-fond<>v-fond1)
   then do: message " ПРОВЕРЬТЕ СУММЫ  ". undo,retry.
  end.
 end.

  displ v-cont v-ref with frame kor.


 update v-rem v-noy v-ser with frame kor.

 find codfr where codfr.codfr="brnchs" no-lock no-error.
 if avail codfr then run sub-codv(kor-acc,"ast","brnchs",codfr.code).
 else if ambiguous codfr then run subcod(kor-acc,"AST").
 else do: message " нет кодификатора : brnchs ". pause. return.
      end.

 update  v-addr validate(can-find(astotv where astotv.kotv= v-addr and astotv.priz = "A"),
         " КОДА " + v-addr + " НЕТ  В СЛОВАРЕ")
         with frame kor.
 find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
 if avail astotv then v-addrn=astotv.otvp.
  displ v-addrn with frame kor.

  update  v-attn validate(can-find(codfr where codfr.codfr = "sproftcn" and
         codfr.code = v-attn and codfr.code matches "..."),
         " КОДА " + v-attn + " НЕТ В СЛОВАРЕ")
          with frame kor.
 find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
 if avail codfr then  v-attnn = codfr.name[1].
  displ v-attnn with frame kor.


  v-arem[1]="Перем. с " + v-ast + " на " + kor-acc.
  update v-arem[1] v-arem[2] v-arem[3] with frame kor.
klud=false.
end.


leave.
end. /*rep  ma */


   if klud then do transaction:
            find fagn where fagn.fag=fag exclusive-lock no-error.
            if kor-acc=string(fag + string(fagn.pednr - 1, "99999")) then
               fagn.pednr= fagn.pednr - 1.
            release fagn.
            return.
  end.


 display v-ast v-gl v-cont kor-acc kor-gl
         v-icost v-nol v-atl v-fond /*amor*/ with frame op.


/*..
 find gl where gl.gl=v-gl no-lock no-error.
  vgln1=gl.gl1.
 find gl where gl.gl=kor-gl no-lock no-error.
  vgln2=gl.gl1.


  if vgln1=vgln2 then amor=0.
  if vgln1<= 0 or vgln2<= 0 then amor=0.
   displ vgln1 vgln2 amor with frame op.
  if vgln1<>vgln2 then
   update amor validate(amor>=0 and amor<=v-nol ,">= 0 un <= " + string(v-nol))
    with frame op.
 /* update vgln1 validate(vgln1=0 or can-find (gl where gl.gl= vgln1)," P–rbaudiet kontu")
         vgln2 validate(vgln2=0 or can-find (gl where gl.gl= vgln2)," P–rbaudiet kontu")
         amor validate(amor>=0 and amor<=v-nol ,"")
    with frame op.
 */
  if vgln1=vgln2 then amor=0.
/*   end.
*/
..*/

 pause 0.

 otv=true.
 klud=true.
 message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
   if not otv then do transaction:
                find fagn where fagn.fag=fag exclusive-lock no-error.
                 if kor-acc=string(fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.
   end.

 if otv then do transaction:

                  create ast.
                   ast.ast=kor-acc.
                   ast.gl=kor-gl.
/*        ?*/        ast.crc=1.
                   ast.fag=fag.
                   ast.name=v-name.
                   ast.addr[1]=v-addr.
                   ast.addr[2]=v-addr2.
                   ast.attn=v-attn.
                   ast.rem=v-rem.
                   ast.noy=v-noy.
                   ast.mfc=v-mfc.
                   ast.ser=v-ser.

                   ast.rdt=v-rdt.
                   ast.icost=v-icost.
                   ast.amt[3]=v-icost - v-nol.
                   ast.salv=v-nol.
                   ast.qty=v-qty.
                   ast.meth=v-qty.
                   ast.who=g-ofc.
                   ast.whn=today.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.

                   ast.ddt[1]=v-ddt.
                   ast.crline=v-crline.
                   ast.ydam[5]=v-ydam5.
                   ast.cont=v-cont.
                   ast.ref=string(v-ref).
                   ast.ldd=v-ldd.

                   ast.ydam[4]=ast.cam[4]. /* ? */

     /* sasco - history for AST departments */
     /* История для исходной карточки */
     create hist.
     hist.pkey = "AST".
     hist.skey = v-ast.
     hist.date = g-today.
     hist.ctime = time.
     hist.who = g-ofc.
     hist.op = "MOVEDEP".
     hist.chval[1] = v-attn.    /* куда */
     hist.chval[2] = old-dep.   /* откуда */
     hist.chval[3] = old-invnr. /* откуда - инв. номер */
     hist.chval[4] = v-addr2.   /* куда - инв. номер */
     hist.chval[5] = v-ast.
     hist.chval[6] = kor-acc.

     /* sasco - history for AST departments */
     /* История для целевой карточки  */
     create hist.
     hist.pkey = "AST".
     hist.skey = kor-acc.
     hist.date = g-today.
     hist.ctime = time.
     hist.who = g-ofc.
     hist.op = "MOVEDEP".
     hist.chval[1] = v-attn.    /* куда */
     hist.chval[2] = old-dep.   /* откуда */
     hist.chval[3] = old-invnr. /* откуда - инв. номер */
     hist.chval[4] = v-addr2.   /* куда - инв. номер */
     hist.chval[5] = v-ast.
     hist.chval[6] = kor-acc.

   arem=trim(trim(v-arem[1]) + " " + trim(v-arem[2]) + " " + trim(v-arem[3])).

   shcode="AST0005".
   vparam=string(v-icost)       + vdel +
          kor-acc               + vdel +
          v-ast                 + vdel +
          arem                  + vdel +
          string(v-nol)         + vdel +
          string(v-fond)        .


   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes,
              input-output s-jh).
   if rcode > 0 or s-jh = 0  then
   do:
         Message " Error: " + string(rcode) + ":" +  rdes .
         pause .
         undo,return . /*next ma.*/
   end.
   else
   do:


      create astjln.
      astjln.ajh = s-jh.
      astjln.aln = 1.
      astjln.awho = g-ofc.
      astjln.ajdt = g-today.
      astjln.arem[1]=substring(v-arem[1],1,55).
      astjln.arem[2]=substring(v-arem[2],1,55).
      astjln.arem[3]=substring(v-arem[3],1,55).
      astjln.arem[4]=substring(v-arem[4],1,55).
      astjln.d[1]=v-icost.
      astjln.c[1]=0.
      astjln.d[3]=0.
      astjln.c[3]=v-nol.
      astjln.d[4]=0.
      astjln.c[4]=v-fond.

      astjln.adc = "D".
      astjln.agl = kor-gl.
      astjln.aqty= v-qty.
      astjln.aast = kor-acc.
      astjln.afag = fag.
      astjln.atrx= "71".
      astjln.ak=v-cont.
      astjln.crline=v-crline.
      astjln.prdec[1]=v-ydam5.
      astjln.icost=v-icost.

      astjln.korgl=v-gl.
      astjln.koracc=v-ast.

      astjln.vop=vop.
      find ast where ast.ast=kor-acc exclusive-lock no-error.
      find first astatl where astatl.agl=ast.gl and astatl.ast=ast.ast and
           astatl.dt=g-today exclusive-lock no-error.
             if not available astatl then create astatl.
             astatl.ast=ast.ast.
             astatl.agl=ast.gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1] . /*ast.icost.*/
             astatl.nol=  ast.cam[3] - ast.dam[3].
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.

      /*                 */

           find ast where ast.ast=v-ast exclusive-lock.
                   ast.icost= ast.dam[1] - ast.cam[1].
                   ast.qty= ast.qty - v-qty.
                  /* ast.crline=ast.crline - v-crline.
                     ast.ydam[5]=ast.ydam[5] - v-ydam5.
                  */
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
      create astjln.
      astjln.ajh = s-jh.
      astjln.aln = 1.
      astjln.awho = g-ofc.
      astjln.ajdt = g-today.
      astjln.arem[1]=substring(v-arem[1],1,55).
      astjln.arem[2]=substring(v-arem[2],1,55).
      astjln.arem[3]=substring(v-arem[3],1,55).
      astjln.arem[4]=substring(v-arem[4],1,55).

      astjln.d[1]=0.
      astjln.c[1]=v-icost.
      astjln.d[3]=v-nol.
      astjln.c[3]=0.
      astjln.d[4]=v-fond.
      astjln.c[4]=0.

        astjln.adc = "C".
      astjln.agl = v-gl.
      astjln.aqty= v-qty.
      astjln.aast = v-ast.
      astjln.afag = v-fag.
      astjln.atrx= "76".
      astjln.ak=v-cont.
      astjln.crline=v-crline.
      astjln.prdec[1]=v-ydam5.
      astjln.icost=v-icost.

      astjln.korgl=kor-gl.
      astjln.koracc=kor-acc.

      astjln.vop=vop.
      find first astatl where astatl.agl=ast.gl and astatl.ast=ast.ast and
           astatl.dt=g-today exclusive-lock no-error.
             if not available astatl then create astatl.
             astatl.ast=ast.ast.
             astatl.agl=ast.gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1] . /*ast.icost.*/
             astatl.nol=  ast.cam[3] - ast.dam[3].
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.




       run x-jlvouR.
       pause 0 .
       klud=false.
   end.
 end. /* tranz*/
/* n */




/**
leave.
end. /*ma*/
**/

if klud then do transaction:
                 find fagn where fagn.fag=v-fag exclusive-lock no-error.
                 if v-ast=string(v-fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.
end.
release ast.
release astatl.
release astjln.
if rcode = 0 and not klud then repeat:
  otv=false.
  message "  Повторить печать?  " UPDATE otv format "да/нет".
 if  otv then do:
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvouR.  pause 0.
 end.
 else leave.
end.














/****

Do transaction on error undo, return:



/*
find jh where jh.jh eq s-jh.

jh.party = "AST".
jh.sts=0.
jh.crc = 1.

vln=0.
klud=true.
def var v as int.
def var vd as dec init 0.
def var vc as dec init 0.

do v=1 to 4:

 if v=1 then do: klud=false.
           find ast where ast.ast=v-ast.
                   ast.icost= ast.icost - v-icost.
                   ast.qty= ast.qty - v-qty.
                   ast.crline=ast.crline - v-crline.
                   ast.ydam[5]=ast.ydam[5] - v-ydam5.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
            release ast.
     v-atrx="76".
     vgl=v-gl. vacc=v-ast. vdam=0. vcam=v-atl.
 end.
 if v=2 then do: klud=false.
             find ast where ast.ast=kor-acc no-error.
             if not avail ast then   create ast.
                   ast.ast=kor-acc.
                   ast.gl=kor-gl.
                   ast.crc=1.
                   ast.fag=fag.
                   ast.name=v-name.
                   ast.addr[1]=v-addr.
                   ast.addr[2]=v-addr2.
                   ast.attn=v-attn.
                   ast.rem=v-rem.
                   ast.noy=v-noy.
                   ast.mfc=v-mfc.
                   ast.ser=v-ser.

                   ast.rdt=v-rdt.
                   ast.icost=v-icost.
                   ast.amt[3]=v-icost - v-nol.
                   ast.salv=v-nol.
                   ast.qty=v-qty.
                   ast.meth=v-qty.
                   ast.who=g-ofc.
                   ast.whn=today.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.

                   ast.ddt[1]=v-ddt.
                   ast.crline=v-crline.
                   ast.ydam[5]=v-ydam5.
                   ast.cont=v-cont.
                   ast.ref=string(v-ref).
                   ast.ldd=v-ldd.
            release ast.
     v-atrx="71".
     vgl=kor-gl. vacc=kor-acc. vdam=v-atl. vcam=0.
 end.

 if v=3 and amor>0 and v-ast<>kor-acc then do: klud=false.
     find gl where gl.gl=v-gl no-lock no-error.
     vgl=gl.gl1. vacc="". vdam=0. vcam=amor.
 end.

 if v=4 and amor>0 and v-ast<>kor-acc then do: klud=false.
     find gl where gl.gl=kor-gl no-lock no-error.
     vgl=gl.gl1. vacc="". vdam=amor. vcam=0.

 end.

 if not klud then do: vln=vln + 1.
 run ast-jls(vln, vgl, vacc, vdam, vcam, v-icost, v-crline, v-ydam5, output otv).
      if not otv then undo,retry.
      klud=true.
      vd= vd + vdam. vc= vc + vcam.
 end.



end. /*do*/

if vd<>vc then do:  message "НЕТ БАЛАНСА...". undo,retry. end.


find first jl where jl.jh=s-jh no-error.
if available jl then do:
  message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
run x-jlvou.
pause 0.
if jh.sts ne 6 then do:
  for each jl of jh:
    jl.sts = 5.
  end.
  jh.sts = 5.
end.
end.


otv=true.
*/
End. /*trans*/


if not otv then do transaction:
                find fagn where fagn.fag=fag exclusive-lock no-error.
                 if kor-acc=string(fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.
end.


***/










