/* cif-dda.p
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

/* cif-dda.p
   Creates/updates DDA/ODA account.
   svl
   changes:
           счета ODA создаются автоматически
*/

{global.i}

def shared var s-aaa like aaa.aaa.
def shared var s-cif like cif.cif.

def new shared var v-lgr like lgr.lgr.
def shared var s-lgr like lgr.lgr.
def var ans as log.

def buffer b-aaa for aaa.
def var qaaa like aaa.aaa.
{cif-dda.f}
find aaa where aaa.aaa eq s-aaa exclusive-lock no-error.

if not available aaa then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.

if aaa.cif ne s-cif then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.
qaaa = s-aaa.
if aaa.craccnt ne "" then find b-aaa where b-aaa.aaa eq aaa.craccnt
exclusive-lock no-error .
if not available b-aaa then aaa.craccnt = "".
/*-------------------------------------------------------------------*/
v-lgr = "5" + substring(s-lgr,2,2).

/*display aaa.aaa aaa.cif aaa.rate aaa.pri aaa.craccnt v-lgr with frame ddaoda.
  pause.*/
if aaa.craccnt eq "" then do:
    repeat while aaa.craccnt eq "" on endkey undo,leave :
      /*  v-lgr = "".
        repeat while v-lgr eq "" on endkey undo,return :
            update v-lgr with frame ddaoda.
            s-lgr = frame-value.
            s-lgr = caps(s-lgr).
       */
            s-lgr = v-lgr.
            find lgr where lgr.lgr eq s-lgr.
            find led where led.led eq lgr.led.

      /*    if lgr.led ne "oda" then v-lgr = "" .
            if lgr.crc ne aaa.crc then v-lgr = "" .
        end.
       */

/*        if (keyfunction(lastkey) eq "GO" or keyfunction(lastkey) eq "RETURN")
        and available lgr
        then do:
               {mesg.i 1808} update ans.
               if ans eq false then return.

               if lgr.nxt eq 0 then do:
                 {mesg.i 1812} update s-aaa.
               end.
               else do:
                 run new-acc.
               end.*/
               /*run acng(input lgr.gl, false, output s-aaa).*/

               run acc_gen(input lgr.gl,lgr.crc,s-cif,'',true,output s-aaa).
               find sysc where sysc.sysc = "branch" no-error.
               find cif where cif.cif = s-cif.
               find aaa where aaa.aaa eq s-aaa exclusive-lock.
               /*
               create aaa.
               aaa.aaa = s-aaa.
               */
               aaa.cif = s-cif.
               aaa.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
               aaa.gl = lgr.gl.
               aaa.lgr = s-lgr.
               if available sysc then aaa.bra = sysc.inval.
               aaa.regdt = g-today.
               aaa.stadt = g-today.
               aaa.stmdt = aaa.regdt - 1.
               aaa.tim = time .
               aaa.who = g-ofc.
               aaa.pass = lgr.type.
               aaa.pri = lgr.pri.
               aaa.rate = lgr.rate.
               aaa.complex = lgr.complex.
               aaa.base = lgr.base.
               aaa.sta = "N".
               aaa.minbal[1] = 9999999999999.99.
               aaa.crc = lgr.crc.
               aaa.base = lgr.base.
               aaa.craccnt = qaaa.
               if led.prgadd ne "" then run value(led.prgadd).
               find b-aaa where aaa.aaa eq b-aaa.aaa.
               find aaa where aaa.aaa eq qaaa.
               aaa.craccnt = b-aaa.aaa.
               display
               aaa.aaa
               aaa.cif
               aaa.rate
               aaa.pri
               aaa.craccnt
               b-aaa.rate
               b-aaa.pri
               b-aaa.cbal
               with frame ddaoda.
      /*  end. */

    end.
end.
else do :
                v-lgr = b-aaa.lgr.
                display
                aaa.aaa
                aaa.cif
                aaa.rate
                aaa.pri
                aaa.craccnt
                v-lgr
                b-aaa.rate
                b-aaa.pri
                b-aaa.opnamt
                b-aaa.cbal
                with frame ddaoda.

end.
/*
find lgr where lgr.lgr eq b-aaa.lgr no-lock.
if lgr.lookaaa eq true then
update b-aaa.rate with frame ddaoda .
update b-aaa.opnamt with frame ddaoda.
b-aaa.cbal = b-aaa.opnamt - b-aaa.dr[1] + b-aaa.cr[1].
*/
display b-aaa.cbal with frame ddaoda.
pause 0.
