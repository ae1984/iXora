/*lclimdoce .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        limit - формирование документов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1 опция Docs
 * AUTHOR
        05/10/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
def shared var s-cif       as char.
def shared var s-number    as int.
def shared var s-ourbank   as char no-undo.

def var v-sel   as int  no-undo.
def new shared   var s-jh like jh.jh.

run sel2('Docs',' Payment Order ', output v-sel).

case v-sel:
    when 1 then do:
        find first lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = s-cif and lclimitres.number = s-number no-lock no-error.
        if avail lclimitres then do:
            for each lclimitres where lclimitres.bank = s-ourbank and lclimitres.cif = s-cif and lclimitres.number = s-number and lclimitres.jh > 0 no-lock:
                s-jh  = 0.
                find first jh where jh.jh = lclimitres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.
end case.