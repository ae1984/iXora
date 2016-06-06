/* dcpdocs .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        DC, ODC - Payment: формирование документов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-8-2-1(2) опция Docs
 * AUTHOR
        13/02/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
 */

{global.i}
def shared var s-lc     like lc.lc.
def shared var s-lcpay  like lcpay.lcpay.
def shared var s-lcprod as char.
def var v-list   as char no-undo init ' Payment Order '.
def var v-sel    as int  no-undo.
def var v-logsno as char no-undo init "no,n,нет,н,1".
def new shared var s-jh like jh.jh .

if s-lcprod = 'idc' then  v-list =  v-list + ' | MT 400 '.
run sel2('Docs',v-list, output v-sel).
case v-sel:
    when 1 then do:
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.jh > 0 no-lock no-error.
        if avail lcpayres then do:
            for each lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.jh > 0 no-lock:
                find first jh where jh.jh = lcpayres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.
    end.
    when 2 then do:
        find first lcpayh where lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'MT400' no-lock no-error.
        if avail lcpayh and lookup(lcpayh.value1,v-logsno) > 0 then do:
            message 'Your choice had not been to create this type of document!' view-as alert-box.
            return.
        end.
        else do:
            run dcmtpay ('400',no).
        end.
    end.
end case.