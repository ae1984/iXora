/* sprav_mko.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Редактироване справочника в кодификаторе с прогрузкой изменений на все базы
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM
 * AUTHOR
     30.11.2009 galina      
 * CHANGES          
        
*/


{mainhead.i}
{comm-txb.i}

def input parameter p-codfr as char.
def buffer v-vcreason for codfr.
def new shared frame vcreason.
def var t4 as char initial "F4-выход,INS-дополн.,P-печать".
def var v-center as logical.
def var v-chng as logical.
def var v-bank as char.


def temp-table t-vcpsreas like codfr.



{apbra.i
&head = "codfr" 
&index = "cdco_idx" 
&formname = "vcreason"
&framename = "vcreason" 
&where = "codfr.codfr = p-codfr" 
&addcon = "true" 
&deletecon = "false"

&postadd = " buffer-copy codfr to t-vcpsreas.
            codfr.codfr = p-codfr. codfr.level = 1. 
            codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. 
            do transaction on endkey undo, leave:
              update codfr.code codfr.name[1] with frame vcreason.             
              run crcupd-after. 
            end. 
            "

&prechoose = "message t4."

&predisplay = " "
&display = "codfr.code codfr.name[1]"
&highlight = "codfr.code"
&predelete = " "
&postdelete = " "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              buffer-copy codfr to t-vcpsreas.
               do transaction on endkey undo, leave:
                update codfr.code /*when v-availupd*/
                       codfr.name[1] /*when v-availupd*/
                       with frame vcreason.             
                run crcupd-after. 
              end. 
             end. "

&end = "run copy2fil. hide frame vcreason.  " 
}

hide message.

procedure crcupd-after.
  v-chng = /*v-center and */
    (codfr.code <> t-vcpsreas.code or codfr.name[1] <> t-vcpsreas.name[1]).
end procedure.

/* переписать важные изменения с головного на филиалы */
procedure copy2fil.
  if v-chng then do:
     message "Синхронизация с филиалами...".
    {r-branch.i &proc = "vcfil1(p-codfr)"}
    hide message no-pause.
  end.
end procedure.



