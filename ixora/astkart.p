/* astkart.p
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
 * BASES
        BANK COMM
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
            24/05/2013 Luiza - ТЗ 1842 закрепление ОС за сотрудником
            27/05/2013 Luiza - перекомпиляция
            19/06/2013 Luiza - ТЗ 1902
            20/06/2013 Luiza - перекомпиляци
*/

/* 11.04.2003 Sasco - запись перемещения по департаментам в историю */
/*                 пункт "Перемещ" - история перемещений по деп-там */

/* k-parsk.p */

/*{mainhead.i FAQRY}*/
define new shared variable v-icost like ast.icost format "zzzzzz,zzz,zz9.99-".
define new shared variable v-atl like ast.icost format "zzzzzz,zzz,zz9.99-".
define new shared variable v-nol like ast.icost format "zzzzzz,zzz,zz9.99-".
define new shared variable v-nach like ast.icost format "zzzzzz,zzz,zz9.99-" .
define new shared variable v-fagn like ast.name.
define new shared variable v-addrn like ast.name.
define new shared variable v-attnn like ast.name.
define new shared variable v-ofc as char.
define variable v-ddt like ast.ldd.
define new shared variable v-fil as char format "x(4)".
define new shared variable v-filn as char format "x(24)".
define variable v-codfr like codfr.codfr.
define new shared variable v-gl3 like trxlevgl.glr.
define new shared variable v-gl4 like trxlevgl.glr.
define new shared variable v-am like trxlevgl.glr.
define new shared variable v-gl3d like gl.des.
define new shared variable v-gl4d like gl.des.
define new shared variable v-gl1d like gl.des.
define new shared variable v-gl1  like ast.gl.

define shared var g-ofc as char.
define shared var g-today as date.
define var v-ownold as char.
define var v-ofcold as char.
define var v-cnt as int.
def var v-yes as logic  no-undo format "Да/Нет" init no.

/* SASCO */

define var old-attn like ast.attn.
define var old-inv  as char.

/* KOVAL */
define new shared variable f-cont  like fagn.cont.
define new shared variable f-ref   like fagn.ref.

/* KOVAL */

def new shared var v-ast like ast.ast format "x(8)".
def new shared var v-fond like ast.icost format "zzzzzz,zzz,zz9.99-".
def var vsele as cha form "x(11)" extent 10
 initial ["Выбор", "Редакт", "Oперации", "Амортиз", "Печать", "Справочн", "Сум.переоц", "Перемещ", "Закрепл","Выход"].

form vsele[1] form "x(5)" vsele[2] form "x(6)" vsele[3] form "x(8)" vsele[4] form "x(7)"
     vsele[5] form "x(6)" vsele[6] form "x(8)" vsele[7] form "x(10)" vsele[8] form "x(7)" vsele[9] form "x(7)" vsele[10] form "x(5)"
     with frame vsele row 21 centered no-label overlay
     title " ВЫБЕРИТЕ И НАЖМИТЕ  <Enter> ".


form
"Обороты :" ast.dam[4] format "zzzzzz,zzz,zz9.99-" " DR "
            ast.cam[4] format "zzzzzz,zzz,zz9.99-" " CR " skip(1)
"Фонд переоценки                     :" v-fond format "zzzzzz,zzz,zz9.99-" skip
/*
"Сумма переоценки основной стоимости :" ast.ydam[4] format "zzzzzz,zzz,zz9.99-" skip
"Сумма переоценки износа             :" ast.ycam[4] format "zzzzzz,zzz,zz9.99-" skip
*/
  with frame pereo row 14 overlay centered no-labels no-hide
    title "  ПРОСМОТР И КОРРЕКТИРОВКА ДАННЫХ ПЕРЕОЦЕНКИ ".

form astofc.fio no-label format "x(40)" validate(trim(astofc.fio) <> "", "Введите ФИО сотрудника ")
with frame fastofc  row 19 overlay  column 52 width 60 no-box.

{astp.f}
hide all.

define temp-table tempofc
    field ofc  as   char
    field name as   char
    index id is primary name.

for each ofc where ofc.ofc begins "id" no-lock.
    find first ofcblok where ofcblok.ofc = ofc.ofc and ofcblok.sts = "u" no-lock no-error.
    if not available ofcblok then do:
        create tempofc.
        tempofc.ofc = ofc.ofc.
        tempofc.name = ofc.name.
    end.
end.
DEFINE QUERY q-ofc FOR tempofc .

DEFINE BROWSE b-ofc QUERY q-ofc
       DISPLAY tempofc.name label "       ФИО   " format "x(30)" tempofc.ofc label "id сотруд" format "x(8)"
       WITH  15 DOWN.
DEFINE FRAME f-ofc b-ofc  WITH overlay 1 COLUMN SIDE-LABELS row 10 COLUMN 45 width 75 NO-BOX.


main:
repeat:

 hide all no-pause.
 clear frame astp.
    prompt ast.ast with frame astp.
    find ast using ast.ast no-lock no-error.
    v-ast=ast.ast.
    if not available ast then do:
        bell. message "AST КАРТ. НЕТ".  undo, retry.
    end.


 find first fagn where fagn.fag = ast.fag no-lock no-error.
 if available fagn then assign
   				v-fagn = fagn.naim
   				f-cont = fagn.cont /* KOVAL */
   				f-ref  = fagn.ref
   				.

m1:
repeat : /*on endkey undo,retry : */

  find ast where ast.ast = v-ast no-lock.
  v-ofc = "".
  if ast.own <> "" then do:
    find first ofc where ofc.ofc = ast.own no-lock no-error.
    if available ofc then v-ofc = ofc.name.
    else do:
        find first astofc where astofc.id = ast.own no-lock no-error.
        if available astofc then v-ofc = astofc.fio.
    end.
  end.

 find first astotv where astotv.kotv = ast.addr[1] and astotv.priz = "A" no-lock no-error.
   if available astotv then v-addrn = astotv.otvp.

 find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.
   if available codfr then v-attnn = codfr.name[1].

  find gl where gl.gl eq ast.gl no-lock no-error.
   if available gl then v-gl1d =gl.des.

  find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 3 no-lock no-error.
   if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.
    v-am = v-gl3.
  find gl where gl.gl eq v-gl3 no-lock no-error.
  if available gl then v-gl3d =gl.des. else v-gl3d="".

  find first trxlevgl where trxlevgl.gl = ast.gl and trxlevgl.lev = 4 no-lock no-error.
   if available trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.
  find gl where gl.gl eq v-gl4 no-lock no-error.
  if available gl then v-gl4d =gl.des. else v-gl4d="".

 find sub-cod where sub-cod.acc = v-ast and sub-cod.sub= "ast"
       and d-cod = "brnchs" no-lock no-error.
 if avail sub-cod then  v-fil = sub-cod.ccode. else v-fil = "".

 find codfr where codfr.codfr = "brnchs" and codfr.code = v-fil no-lock no-error.
 if avail codfr then v-filn = codfr.name[1]. else v-filn="".
    v-icost= ast.dam[1] - ast.cam[1].
    v-atl = ast.dam[1] - ast.cam[1] + ast.dam[3] - ast.cam[3].
    v-nol = ast.cam[3] - ast.dam[3].
    v-nach = ast.amt[3] + ast.salv.
    v-fond = ast.cam[4] - ast.dam[4].

    display
    ast.ast ast.addr[2] ast.name ast.fag v-fagn ast.gl
    v-gl1d v-gl3 v-gl3d ast.rdt ast.noy ast.qty ast.ser v-icost ast.whn /* ast.who */
    f-cont /* ast.cont */ ast.ref f-ref ast.ddt[1] ast.crline ast.dam[5] ast.ddt[4] ast.amt[4] ast.cam[4]
    v-fil v-filn
    ast.salv v-atl v-nol v-nach ast.meth ast.ldd ast.noy ast.amt[1]
    ast.addr[1] v-addrn ast.attn v-attnn ast.mfc ast.rem ast.own v-ofc ast.updt ast.ofc
    ast.dam[1] ast.cam[1] /*ast.ydam[5]*/ ast.dam[3] ast.cam[3]
    with frame astp.

    pause 0.
    display vsele with frame vsele.

    choose field vsele auto-return with frame vsele.
    hide frame vsele.
    if frame-value = "Редакт"
    then do:
         find ast where ast.ast=v-ast exclusive-lock.
         old-inv = ast.addr[2].
         update  ast.addr[2] ast.name  ast.rdt v-nach ast.meth ast.salv
                 ast.noy validate(ast.noy>=0," >=0") /*ast.amt[1]*/ ast.ser
                 ast.ldd ast.ref /* ast.cont */
                 with frame astp.

         ast.amt[3]= v-nach - ast.salv.
         update  ast.addr[1] validate(can-find(astotv where astotv.kotv = ast.addr[1] and astotv.priz = "A"),
             " Кода " + ast.addr[1] + " нет в словаре") with frame astp.
         find first astotv where astotv.kotv = ast.addr[1] and astotv.priz = "A" no-lock no-error.
         if available astotv then do: v-addrn = astotv.otvp.
                                  displ v-addrn with frame astp.
                               end.

         old-attn = ast.attn.
         update   ast.attn validate(can-find(codfr where codfr.codfr = "sproftcn" and
            codfr.code = ast.attn and codfr.code matches '...'),
                 "Кода " + ast.attn + " нет в словаре") with frame astp.
         find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.
         if available codfr then do: v-attnn = codfr.name[1].
                                  displ v-attnn with frame astp.
                               end.
         if ast.attn <> old-attn then do:
            create hist.
            assign hist.date = g-today
                   hist.who = g-ofc
                   hist.ctime = time
                   hist.pkey = "AST"
                   hist.skey = ast.ast
                   hist.op = "MOVEDEP"
                   hist.chval[1] = ast.attn  /* новый деп. */
                   hist.chval[2] = old-attn  /* старый деп. */
                   hist.chval[3] = old-inv   /* старый инв.н. */
                   hist.chval[4] = ast.addr[2]. /* новый инв.н. */
         end.
         v-ownold = ast.own.
         v-ofcold = v-ofc.
         update ast.rem  with frame astp.
         repeat:
            update v-ofc  with frame astp.
            if v-ofc = "" and v-ofcold <> v-ofc then do:
                message "Снять закрепление ОС?"  view-as alert-box question buttons yes-no title "" update v-yes .
                if v-yes then do:
                    ast.own = "".
                    ast.whnown = g-today.
                    v-ofc = "".
                    create astown.
                    astown.ast = ast.ast.
                    astown.own = "".
                    astown.who = g-ofc.
                    astown.whn = g-today.
                    find current astown no-lock no-error.
                    displ ast.own v-ofc with frame astp.
                    leave.
                end.
                else do:  /* если отказываемся снимать закрпление */
                    v-ofc = v-ofcold.
                    displ v-ofc with frame astp.
                    leave.
                end.
            end.
            if v-ofc = v-ofcold then leave.
            v-cnt = 0.
            find first ofc where ofc.ofc = v-ofc no-lock no-error.
            if available ofc then v-ofc = ofc.name.
            if v-ofc begins "id" then do:
                find first astofc where astofc.id = v-ofc no-lock no-error.
                if available astofc then do:
                    ast.own = v-ofc.
                    v-ofc = astofc.fio.
                    displ ast.own v-ofc with frame astp.
                end.
                else do:
                    create astofc.
                    astofc.id = v-ofc.
                    ast.own = v-ofc.
                    update astofc.fio  with frame fastofc.
                    astofc.who = g-ofc.
                    astofc.whn = g-today.
                    v-ofc = astofc.fio.
                    displ ast.own v-ofc with frame astp.
                end.
                if v-ownold <> ast.own  then do: /* сохраняем историю закрепления ОС */
                    ast.whnown = g-today.
                    create astown.
                    astown.ast = ast.ast.
                    astown.own = ast.own.
                    astown.who = g-ofc.
                    astown.whn = g-today.
                    find current astown no-lock no-error.
                end.
                leave.
            end.
            else do:
                FOR EACH tempofc where tempofc.name MATCHES "*" + trim(v-ofc) + "*" no-lock.
                    v-cnt = v-cnt + 1.
                end.
                if v-cnt = 0 then message "Сотрудник не найден" view-as alert-box.
                else do:
                    OPEN QUERY  q-ofc FOR EACH tempofc where tempofc.name MATCHES "*" + trim(v-ofc) + "*" no-lock.
                    ENABLE ALL WITH FRAME f-ofc.
                    wait-for return of frame f-ofc
                    FOCUS b-ofc IN FRAME f-ofc.
                    v-ofc = tempofc.name.
                    ast.own = tempofc.ofc.
                    if v-ownold <> ast.own then ast.whnown = g-today.
                    hide frame f-ofc.
                    displ ast.own v-ofc with frame astp.
                    if v-ownold <> ast.own  then do: /* сохраняем историю закрепления ОС */
                        create astown.
                        astown.ast = ast.ast.
                        astown.own = ast.own.
                        astown.who = g-ofc.
                        astown.whn = g-today.
                        find current astown no-lock no-error.
                    end.
                    leave.
                end.
            end.
         end.
        if keyfunction (lastkey) = "end-error" then do:
            v-ofc = v-ofcold.
            displ v-ofc with frame astp.
        end.
        update ast.mfc with frame astp.
        find ast where ast.ast = v-ast no-lock.
        next m1.
    end.
    else if frame-value = "Выбор" then next main.
    else if frame-value = "Выход"
    then return.

    else if frame-value = "Oперации"
     then do: run astopr1("1").
              find ast where ast.ast = v-ast no-lock no-error.
              if not avail ast then return.
              next m1.
     end.
    else if frame-value = "Амортиз"
     then do: run astopr1("2").
              find ast where ast.ast = v-ast no-lock no-error.
              if not avail ast then return.
              next m1.
     end.
    else if frame-value = "Печать"

     then do: run r-astdruk.
     find ast where ast.ast = v-ast no-lock.
              next m1.
     end.
     else if frame-value = "Справочн"

     then do: run subcod(v-ast,"ast").
     find ast where ast.ast=v-ast no-lock.
              next m1.
     end.
     else if frame-value = "Сум.переоц"
     then do :
       /*find ast where ast.ast=v-ast exclusive-lock.
       */
       v-fond = ast.cam[4] - ast.dam[4].
       displ   ast.dam[4] ast.cam[4] v-fond  /*ast.ydam[4] ast.ycam[4]*/
               with frame pereo.
      /*
       repeat:
        update ast.ydam[4] ast.ycam[4] with frame pereo.
        if ast.ydam[4] - ast.ycam[4] eq v-fond then leave.
       end.
      */
       find ast where ast.ast=v-ast no-lock.
        next m1.
     end.
     else if frame-value = "Перемещ"
     then do:
              run astdepmov (ast.ast).
              find ast where ast.ast = v-ast no-lock no-error.
              if not avail ast then return.
              next m1.
     end.
     else if frame-value = "Закрепл"
     then do:
              run astown(ast.ast).
              find ast where ast.ast = v-ast no-lock no-error.
              if not avail ast then return.
              next m1.
     end.
end.
end.
