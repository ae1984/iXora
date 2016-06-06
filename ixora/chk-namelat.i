/* chk-namelat.i
 * MODULE
        Платежные карты
 * DESCRIPTION
        Функция проверки реквизита на латинице
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        17.05.2013 Lyubov
 * BASES
        BANK
 * CHANGES
 */

  function chk-namelat returns logi (p-namelat as char).
    def var v-err as logi no-undo.
    def var k     as int  no-undo.
    def var v-lat as char no-undo init "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".
    do k = 1 to length(p-namelat).
        if not can-do(v-lat,substr(p-namelat,k,1)) then do:
            v-err = yes.
            leave.
        end.
    end.
    return v-err.
  end function.
