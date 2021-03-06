#INCLUDE "PROTHEUS.CH"

#define STR0001  "OP's Previstas"
#define STR0002  "Firma OPs"
#define STR0003  "Exclui OPs"
#define STR0004  " Firma as OPs marcadas ?"
#define STR0005  " Deleta as OPs marcadas ?"
#define STR0006  "Selecionando Registros..."
#define STR0007  "Pesquisar"
#define STR0008  "Aten��o"
#define STR0009  "Todas as OPs intermedi�rias que possuam vinculo com alguma OP Pai marcada no Browse, ser�o firmadas, "
#define STR0010  "devido o sistema estar parametrizado para trabalhar com produ��o autom�tica (MV_PRODAUT habilitado). "
#define STR0011  "Deseja continuar o processo ?"
#define STR0012  "Sim"
#define STR0013  "N�o"
#define STR0014  "Deletando OP's previstas..."
#define STR0015  "Deletando SC's previstas..."
#define STR0016  "Deletando PC's/CP's previstos..."
//---------------------------------
/*
Este Programa controla as liberacoes de plano de producao por usuario. Especifico Midori. Desenvolvido por Rogerio Nunes em 03/02/10.
*/
User Function AGF_GERFIC()
Local	nI			:= 0
Local 	aCampos		:= {}
Local nn1
Private cMarca 		:= GetMark()
Private nOrdemAtual := 10
Private cusrs := Getmv( 'MV_MIDOLBPL'  )
Private aUsrs := U_QuebraSep( cusrs , ';'  )
Private cUsuPermit  := ''
Private oOk := LoadBitmap( GetResources(), "LBOK")
Private oNo := LoadBitmap( GetResources(), "LBNO")
//
For nn1 := 1 to len( aUsrs )
	cUsuArray := aUsrs[ nn1 ]
	//
	if Alltrim(substr( cUsuArray  , 2 ) )   == Alltrim( RetCodUsr()   )
		cUsuPermit  := aUsrs[ nn1 ]
		exit
	Endif
Next
//
/*
if cUsuPermit == ''
	Alert('Aten��o !!! Voc� N�o tem direito a utilizar esta rotina. Entre em contato com o Administrador do sistema.')
	Return()
Endif
*/
//
//����������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa  �
//� ----------- Elementos contidos por dimensao ------------ �
//� 1. Nome a aparecer no cabecalho                          �
//� 2. Nome da Rotina associada                              �
//� 3. Usado pela rotina                                     �
//� 4. Tipo de Transa��o a ser efetuada                      �
//�    1 - Pesquisa e Posiciona em um Banco de Dados         �
//�    2 - Simplesmente Mostra os Campos                     �
//�    3 - Inclui registros no Bancos de Dados               �
//�    4 - Altera o registro corrente                        �
//�    5 - Remove o registro corrente do Banco de Dados      �
//�    6 - Altera determinados campos sem incluir novos Regs �
//������������������������������������������������������������

//����������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes               �
//������������������������������������������������������������
Private cCadastro := "Planos de Produ��o"

Private aRotina := MnuMonta()
Private aIndTmp 	:= {}
Private aSavMTA652  := Array(8)
Private oVermelho   := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAmarelo    := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oVerde      := LoadBitmap( GetResources(), "BR_VERDE" )

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis para rotina de inclusao automatica    �
//����������������������������������������������������������������


//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // De  Produto                           �
//� mv_par02            // Ate Produto                           �
//� mv_par03            // De  Ordem de Producao                 �
//� mv_par04            // Ate Ordem de Producao                 �
//� mv_par05            // De  Data de Entrega                   �
//� mv_par06            // Ate Data de Entrega                   �
//� mv_par07            // De  Data de Inicio                    �
//� mv_par08            // Ate Data de Inicio                    �
//����������������������������������������������������������������

Pergunte("MTA652",.F.)
For ni := 1 to 8
	aSavMTA652[ni] := &("mv_par"+StrZero(ni,2))
Next ni



dbSelectArea("SZP")
dbSetOrder(2)
//����������������������������������������������������������Ŀ
//� Filtra o arquivo conforme perguntas antes de mostrar     �
//� o browse                                                 �
//������������������������������������������������������������
  PLNPFiltra()
//set filter to ZP_FILIAL== xFilial("SZP") .And. ZP_LIBER == "OK" //.and. (ZP_ANO == cValToChar(Year(dDatabase))) //.or. ZP_ANO = '2013')
dbGoTop()
// MarkBrow("SC2","C2_OK",  ,  ,   , cMarca)
//
aCampos := {}
AADD(aCampos,{"ZP_OK"    		,"",""     	})
AADD(aCampos,{"ZP_OPMIDO"    		,"","Num. Plano "     	})
AADD(aCampos,{"ZP_EMISSAO"  		,"","Emissao"  		  	})
AADD(aCampos,{"ZP_QUANT"    		,"","Quantidade"    	})
AADD(aCampos,{"ZP_PRODUTO"  		,"","Produto"   		})
AADD(aCampos,{"ZP_CLIENTE"    		,"","Cliente"    		})
AADD(aCampos,{"ZP_LOJA"    			,"","Loja"    			})
AADD(aCampos,{"ZP_NOMCLIE"    		,"","Nome"     			})
AADD(aCampos,{"ZP_RELEASE"    		,"","Release"    		})
AADD(aCampos,{"ZP_DTRELEA"    		,"","Release"    		})
AADD(aCampos,{"ZP_NMLIB1"    		,"","1 Liberacao"   	})
AADD(aCampos,{"ZP_DTLIB1"    		,"","Data"    			})
AADD(aCampos,{"ZP_NMLIB2"    		,"","2 Liberacao"   	})
AADD(aCampos,{"ZP_DTLIB2"    		,"","Data"    			})
AADD(aCampos,{"ZP_EMISSAO"    		,"","Impr. Ficha"    	})
//
aCores := {} // Limpando a variavel
//Aadd(aCores,{"empty(C2_USLIB1) .and. empty(C2_USLIB2) .AND. C2_LIBER <>'OK' "    ,"BR_VERMELHO" })
//Aadd(aCores,{"! empty(C2_USLIB1) .and. empty(C2_USLIB2) .AND. C2_LIBER <>'OK'  " ,"BR_AMARELO"   })
//
// MarkBrow("SC2","C2_OK", ,aCampos ,  , cMarca , , , , , , , , ,  )
MarkBrow("SZP","ZP_OK", ,aCampos ,  , cMarca , , , , , , , , ,  )
//
//��������������������������������������������������������������Ŀ
//� Retorna indices do SC2                                       �
//����������������������������������������������������������������

RetIndex("SZP")
aEval(aIndTmp, {|cFile| fErase(cFile+OrdBagExt())})
dbSetOrder(1)

RETURN
//----------------------------------
Static FUNCTION PLNPFiltra(nOrder)
LOCAL cIndice,nInd,cFirmaCond:=""
Local cNomeInd:=CriaTrab(NIL,.F.)
nOrder := If(nOrder=Nil,2,nOrder)

Aadd(aIndTmp, cNomeInd)
//��������������������������������������������������������������Ŀ
//� Gera index de trabalho do SC2                                �
//����������������������������������������������������������������
dbSelectArea("SZP")
dbSetOrder(2)
cIndice   := Indexkey()
cFirmaCond += 'ZP_FILIAL=="'+xFilial("SZP")+'".And. '
cFirmaCond += ' ZP_LIBER == "OK" '  
cFirmaCond += ' .and. ZP_ANO = "'+cValToChar(Year(dDatabase))+'" '

//
IndRegua("SZP",cNomeInd,cIndice,,cFirmaCond,STR0006)	//"Selecionando Registros..."
nInd := RetIndex("SZP")
#IFNDEF TOP
	dbSetIndex(cNomeInd+OrdBagExt())
#ENDIF
dbSetOrder(nInd+1)
Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MA651Filtro � Autor �Rodrigo de A Sartorio� Data � 03/02/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Estabelece o topo e o Fim da markbrowse                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MA651Filtro                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA651                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
Function MA651Filtro(lTop)
Local cRetorno := ""
If lTop
cRetorno:=xFilial("SC2")+"P"
Else
cRetorno:=xFilial("SC2")+Repl(Chr(255),Len(SC2->C2_TPOP))
EndIf
Return(cRetorno)
*/
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabio Alves Silva     � Data �08/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MnuMonta()

PRIVATE aRotina	:= {}
AaDd( aRotina	,	{"Pesquisar"         		,"aXPesqui"	,0,1,0,.f.} )
AaDd( aRotina	,	{'Visualizar ' 				,"U_VISUP"	,0,4,0,.f.} ) 
//
if cUsuPermit <> ''
   AaDd( aRotina	,	{'Fichas de Corte' 	    ,"U_AGF_DETFHC( SC2->(RECNO() )  )",0,5,0,.f.} )
Endif 
//
AaDd( aRotina	,	{'Status PLano' 	        ,"U_StatFic()" ,0,5,0,.f.} )
AaDd( aRotina	,	{'Legenda '					,"u_Mid_LegPlP"   ,0,5,0,.f.} )
									
// U_MD_GRFCOR(  SC2->(RECNO() )  )
//-------------------------
Return(aRotina)
//------------------------------------------------------------------------------------------------
Static Function ChvFic()
Return('ZP_FILIAL== xFilial("SZP").And. ZP_LIBER == "OK" ')
//------------------------------------------------------------------------------------------------

/*USer   Function QuebraSep( Linha , cSep  )  // A Variavel cSep indica qual o separador que servira para a quebra do item e alimentacao da array
Local aItens1 := {} // Array que sera preenchida a partir da quebra dos itens
Local cDsAux := ''
Local n1 := 1
//
For n1 := 1 to len( Linha )
	if substr(linha,n1,1) <> csep
		cDsAux += substr(linha,n1,1)
	Else
		AAdd( aItens1, cDsAux )
		cDsAux := ''
	Endif
	//
Next
// Adicionando o ultimo elemento da quebra com o item
if cDsAux <> ''
	AAdd( aItens1, cDsAux )
Endif
//
//
Return( aitens1 )
//--------------------------------------------------------