#INCLUDE "PROTHEUS.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "PONCALEN.CH"

#define STR0001  "Relatorio para Autorizacao do Pagamento de Horas Extras"
#define STR0002  "Ser� impresso de acordo com os parametros solicitados pelo"
#define STR0003  "usuario."
#define STR0004  "Matricula"
#define STR0005  "Centro de Custo"
#define STR0006  "Nome"
#define STR0007  "Turno"
#define STR0008  "Zebrado"
#define STR0009  "Administracao"
#define STR0011  "Autorizacao do Pagamento de Horas Extras"
#define STR0012  "Chapa Matr.  Funcionario                         Data   Cod Descricao            Horas              Visto"
#define STR0013  ""
#define STR0014  ""
#define STR0015  "C.C: "
#define STR0016  "    C.C: "
#define STR0017  "Filial: "
#define STR0018  " Turno: "
#define STR0019  "    C.C: "
#define STR0020  "C.Custo+Nome"
#define STR0021  "Selecione a o��o de impress�o: "
#define STR0022  "Por Per�odo"
#define STR0023  "Por Datas"
#define STR0024  "Processo: "
#define STR0025  "Per�odo:"
#define STR0026  "Roteiro: "
#define STR0027  "Num. Pagto: "
#define STR0028  "Departamento"
#define STR0029  "Depto: "

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PONR060  � Autor � R.H. - J. Ricardo     � Data � 12.08.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Autorizacao do Pagamento de Horas Extras                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PONR060(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Marinaldo   �06/04/01�Melhor�Retirada da Funcao fDescTno() que era esta���
���            �--------�------�tica no Programa para utilizacao da  fDesc���
���            �--------�------�tno() Existente no PonxFun().             ��� 
���Mauricio MR �27/02/02�Melhor�A)Inclusao da GetMarcacoes em substituicao��� 
���            �        �      �do algoritimo anterior para tratar a lei -���  
���            �        �      �tura do SP8(marcacoes).                   ���  
���            �        �      �B)Inclusao do PonCalen.ch e substituicao  ���  
���            �        �      �dos indices dos arrays pelas Constantes   ���  
���            �        �      �correspondentes.                          ���  
���Marinaldo   �28/02/02�Melhor�Inclusao da Funcao fChkSX1() que ira inici���
���            �        �      �alizar as Datas de Acordo com o Periodo de���  
���            �        �      �Apontamento que sera montado a partir   da���  
���            �        �      �Data Base do Sistema					  ���  
��� Priscila R.�04/06/02�------�Ajuste no relatorio para que seja impresso��� 
���            �--------�------�corretamente o C.C no tamanho 20.         ��� 
���Mauricio MR �04/12/02�------�Retirada a restricao de existencia de cra-��� 
���            �--------�------�cha para a emissao do relatorio.	      ��� 
���Mauricio MR �20/10/03�Melhor�Considera horas extras interjornadas e    ��� 
���            �        �      �de nona hora.							  ��� 
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Programador  � Data     � FNC            �  Motivo da Alteracao                      ���
���������������������������������������������������������������������������������������ĳ��
���Rogerio R.   �29/07/2009�00000018267/2009�Compatibilizacao dos fontes para aumento do���
���             �          �                �campo filial e gest�o corporativa.         ���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/        

//Vinicius Schwartz - TI - Midori Atlantica - 07/08/2012            
//Filtro para ser impresso somente os casos onde ultrapassa o horario de risco (acima de 2 horas)
//Inicio de manutencao

User Function MD_PONR060()
//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais (Basicas)                            �
//����������������������������������������������������������������
Local cDesc1  := STR0001  // 'Relatorio para Autorizacao do Pagamento de Horas Extras'
Local cDesc2  := STR0002  // 'Ser� impresso de acordo com os parametros solicitados pelo'
Local cDesc3  := STR0003  // 'usuario.'
Local cString :='SRA' // alias do arquivo principal (Base)
Local aOrd    := {STR0004 ,STR0005 ,STR0006 ,STR0007, STR0020 } // 'Matricula'###'Centro de Custo'###'Nome'###'Turno'###'C.Custo+Nome'
Local wnRel

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Basicas)                            �
//����������������������������������������������������������������
Private aReturn    := { STR0008 , 1,STR0009 , 1, 2, 1, '',1 } // 'Zebrado'###'Administracao'
Private nomeprog   := 'PONR060'
Private aLinha     := {}
Private aTabPadrao := {}
Private nLastKey   := 0
Private cPerg      := 'PNR060'

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na funcao IMPR                          �
//����������������������������������������������������������������
Private Titulo   := OemToAnsi(STR0011 ) // 'Autorizacao do Pagamento de Horas Extras'
Private cCabec   := ''
Private AT_PRG   := 'PONR060'
Private wCabec0  := 1
PRIVATE wCabec1  := STR0012  // "Chapa Matr.  Funcionario                         Data   Cod Descricao            Horas      Visto"
Private ContFl   := 1
Private Li       := 0
Private nTamanho := 'N'

//��������������������������������������������������������������Ŀ
//� Define Variaveis Private(Programa)                           �
//����������������������������������������������������������������
Private nOrdem   := 0
Private aInfo    := {}

Begin Sequence

	//-- Par�metro MV_PAPONTA
	Private dPerIni := CTOD('  /  /  ')
	Private dPerFim := CTOD('  /  /  ')
	If !PerAponta(@dPerIni,@dPerFim)
		Break
	Endif

	//��������������������������������������������������������������Ŀ
	//� Atualiza as Datas no SX1                                     �
	//����������������������������������������������������������������
	fChkSX1( dPerIni , dPerFim , cPerg )

	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas                           �
	//����������������������������������������������������������������
	Pergunte( cPerg , .F. )
	
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� MV_PAR01        //  Filial  De                               �
	//� MV_PAR02        //  Filial  Ate                              �
	//� MV_PAR03        //  Centro de Custo De                       �
	//� MV_PAR04        //  Centro de Custo Ate                      �
	//� MV_PAR05        //  Turno De                                 �
	//� MV_PAR06        //  Turno Ate                                �
	//� MV_PAR07        //  Matricula De                             �
	//� MV_PAR08        //  Matricula Ate                            �
	//� MV_PAR09        //  Nome De                                  �
	//� MV_PAR10        //  Nome Ate                                 �
	//� MV_PAR11        //  Situacao                                 �
	//� MV_PAR12        //  Categoria                                �
	//� MV_PAR13        //  Imprime C.C em outra Pagina              �
	//� MV_PAR14        //  Dia Inicial                              �
	//� MV_PAR15        //  Dia Final                                �
	//� MV_PAR16        //  Autorizadas/Nao Autorizadas/Ambas        �
	//� MV_PAR17        //  Relatorio Sintetico/Analitico            �
	//� MV_PAR18        //  Quebra Func.Pag. Sim/Nao                 �
	//� MV_PAR19        //  Imprimir Marca��es                       �
	//� MV_PAR20        //  Regra De                                 �
	//� MV_PAR21        //  Regra Ate                                �
	//����������������������������������������������������������������
	
	//��������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT                        �
	//����������������������������������������������������������������
	wnRel := 'PONR060' //-- Nome Default do relatorio em Disco
	wnRel := SetPrint(cString, wnRel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F., aOrd,,nTamanho)
	
	//��������������������������������������������������������������Ŀ
	//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
	//����������������������������������������������������������������
	nOrdem    := aReturn[8]
	FilialDe  := MV_PAR01
	FilialAte := MV_PAR02
	CcDe      := MV_PAR03
	CcAte     := MV_PAR04
	TurDe     := MV_PAR05
	TurAte    := MV_PAR06
	MatDe     := MV_PAR07
	MatAte    := MV_PAR08
	NomDe     := MV_PAR09
	NomAte    := MV_PAR10
	cSit      := MV_PAR11
	cCat      := MV_PAR12
	lCC       := If(MV_PAR13 == 1, .T., .F.)
	nTipHoras := MV_PAR16
	nSinAna   := MV_PAR17
	lImpFol	  := If(MV_PAR18 == 1,.T.,.F.)
	lImpMar   := IF(MV_PAR19 == 1,.T.,.F.)
	RegDe     := MV_PAR20
	RegAte    := MV_PAR21	

	If MV_PAR14 > MV_PAR15
		Help(' ', 1, 'PNR050DATA')
		Break
	Endif

	If	nLastKey == 27
		Break
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Break
	Endif

	dInicio := MV_PAR14
	dFim    := MV_PAR15

	//��������������������������������������������������������������Ŀ
	//� Carrega todas as tabelas de hor�rio                          �
	//����������������������������������������������������������������
	If !fTabTurno(aTabPadrao)
		Break
	EndIf

	cCabec := STR0001  // 'Relatorio para Autorizacao do Pagamento de Horas Extras'

	Titulo := OemToAnsi(cCabec)

    RptStatus({|lEnd| PO060Imp(@lEnd,wnRel,cString)},Titulo)

End Sequence	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PO060Imp � Autor � R.H. - J. Ricardo     � Data � 10.04.96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Autorizacao de Horas Extras                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � PO060Imp(lEnd,wnRel,cString)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd        - A��o do Codelock                             ���
���          � wnRel       - T�tulo do relat�rio                          ���
���Parametros� cString     - Mensagem                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PO060Imp(lEnd,WnRel,cString)
Local aAutorizado  := {}
Local xQuant
Local nPos         := 0
Local cPD          := Space(03)
Local cAcessaSRA   := &("{ || " + ChkRH("PONR060","SRA","2") + "}")
Local cAcessaSPC   := &("{ || " + ChkRH("PONR060","SPC","2") + "}")
Local cOrdem	   := ''
Local cCod029A	   := ''
Local cCod025A	   := ''
Local nFor		   := 0
Local nMar		   := 0

Private aItens     := {}
Private lCabec     := .F.
Private lCabecCC   := .F.
Private lCabecTT   := .F.
Private lPrimeira  :=.T.
Private aMarcFun   :={}
Private aTabPadrao := {}
Private aTabCalend := {}
Private nPosMarc   := 0 
Private nLenMarc   := 0

//��������������������������������������������������������������Ŀ
//� Carrega todas as tabelas de hor�rio                          �
//����������������������������������������������������������������
If !fTabTurno(aTabPadrao)
	Return Nil
EndIf

dbSelectArea( "SRA" )
dbGoTop()
DbSetOrder(nOrdem)
If nOrdem == 1
	dbSeek(FilialDe + MatDe,.T.)
    cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := FilialAte + MatAte
ElseIf nOrdem == 2
	dbSeek(FilialDe + CcDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := FilialAte + CcAte + MatAte
	lCabecCC := IF(!lImpFol,.T.,.F.)
ElseIf nOrdem == 3
	dbSeek(FilialDe + NomDe + MatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim     := FilialAte + NomAte + MatAte
ElseIf nOrdem == 4
	dbSeek(FilialDe + TurDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_TNOTRAB"
	cFim     := FilialAte + TurAte
	lCabecTT := IF(!lImpFol,.T.,.F.)
ElseIf nOrdem == 5
	dbSetOrder(8)
	dbSeek(FilialDe + CcDe + NomDe,.T.)
	cInicio  := 'SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_NOME'
	cFim     := FilialAte + CcAte + NomAte
Endif

SetRegua(SRA->(RecCount()))

cTnoAnt      := Replicate("�", GetSx3Cache("RA_TNOTRAB", "X3_TAMANHO"))
cSeqAnt      := Replicate("�", GetSx3Cache("RA_SEQTURN", "X3_TAMANHO"))
aTabOPadrao  := {}
aTabOrigin   := {}
aTabCalend   := {}
cFilAnterior := Replicate("@", FWGETTAMFILIAL)
cTurnoant    := Replicate("@", GetSx3Cache("RA_TNOTRAB", "X3_TAMANHO"))
cCcAnt       := Replicate("@", GetSx3Cache("RA_CC", "X3_TAMANHO"))

dbSelectArea( "SRA" )
While !EOF() .And. &cInicio <= cFim
	IncRegua()

	If lEnd
		IMPR(cCancela,"C")
		Exit
	EndIF

	//��������������������������������������������������������������Ŀ
	//� Consiste controle de acessos e filiais validas               �
	//����������������������������������������������������������������
	If SRA->( !(RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA) )
		SRA->(dbSkip())
		Loop
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Consiste Parametrizacao do Intervalo de Impressao            �
	//����������������������������������������������������������������
	If (SRA->RA_Nome < NomDe)    .Or. (SRA->RA_Nome > NomAte) .Or. ;
		(SRA->RA_Mat < MatDe)     .Or. (SRA->RA_Mat > MatAte)  .Or. ;
		(SRA->RA_CC < CcDe)       .Or. (SRA->RA_CC > CCAte) .OR. ;
		(Sra->RA_TNOTRAB < TurDe) .Or. (SRA->RA_TNOTRAB > TurAte) .Or. ;
		(Sra->RA_REGRA < RegDe)   .Or. (SRA->RA_REGRA > RegAte)
		Sra->(dbSkip())
		Loop
	Endif

	If (SRA->RA_DEMISSA < dInicio .AND. ! Empty(SRA->RA_DEMISSA))
		SRA->(DbSkip())
		Loop
	Endif

	If !(Sra->Ra_SitFolh $ cSit) .Or. !(Sra->Ra_CatFunc $ cCat)
		DbSkip()
		Loop           // Testa Categoria e Situacao
	Endif

	If SRA->RA_FILIAL != cFilAnterior // quebra filial
		lCabec := .T.
		cFilAnterior:= SRA->RA_FILIAL
		cTurnoAnt	:= Replicate("@", GetSx3Cache("RA_TNOTRAB", "X3_TAMANHO"))
		cCcAnt		:= Replicate("@", GetSx3Cache("RA_CC", "X3_TAMANHO"))
	Endif

	If nOrdem == 4 .And. cTurnoAnt != SRA->RA_TNOTRAB 
		If !lImpFol
			lCabecTT := .T.
		Endif
		cCcAnt    := Replicate("@", GetSx3Cache("RA_CC", "X3_TAMANHO"))
		cTurnoAnt := SRA->RA_TNOTRAB
	Endif

	If (nOrdem = 2 .Or. nOrdem == 5) .AND. SRA->RA_CC != cCcAnt
		If lCc
			lCabec := .T.
		Endif
		lCabecCC := .T.
	Endif
	
	cCcAnt 		:= SRA->RA_CC
	cTurnoAnt	:= SRA->RA_TNOTRAB
	dDtMarc		:= CtoD("  /  /  ")

	//�������������������������������������������������������������Ŀ
	//� Cria Calendario de Marca�oes do Periodo                     �
	//���������������������������������������������������������������
	If cTnoAnt + cSeqAnt != SRA->RA_TNOTRAB + SRA->RA_SEQTURN
		cTnoAnt    := SRA->RA_TNOTRAB
		cSeqAnt    := SRA->RA_SEQTURN	
	Endif
    
	//-- Cria Calendario com o periodo completo com Trocas de Turno
	aTabCalend := {} ; aTurnos   := {} ; aMarcacoes := {}

	//-- Carrega as Marcacoes do Periodo
	IF !GetMarcacoes( @aMarcacoes		,;	//Marcacoes dos Funcionarios
					  @aTabCalend		,;	//Calendario de Marcacoes
					  @aTabPadrao		,;	//Tabela Padrao
					  @aTurnos			,;	//Turnos de Trabalho
					  dPerIni 			,;	//Periodo Inicial
					  dPerFim			,;	//Periodo Final
					  SRA->RA_FILIAL	,;	//Filial
					  SRA->RA_MAT		,;	//Matricula
					  SRA->RA_TNOTRAB	,;	//Turno
					  SRA->RA_SEQTURN	,;	//Sequencia de Turno
					  SRA->RA_CC		,;	//Centro de Custo
					  "SP8"				,;	//Alias para Carga das Marcacoes
					  .F.    			,;	//Se carrega Recno em aMarcacoes
					  .T.      			,;	//Se considera Apenas Ordenadas
					  .T.      			,;	//Se Verifica as Folgas Automaticas
					  .F.      			 ;	//Se Grava Evento de Folga Automatica Periodo Anterior
					)
		Set Device to Screen
		Help(' ',1,'PONSCALEND')
		Set Device to Printer
		cTnoAnt := Replicate("�", GetSx3Cache("RA_TNOTRAB", "X3_TAMANHO"))
		cSeqAnt := Replicate("�", GetSx3Cache("RA_SEQTURN", "X3_TAMANHO"))
		Sra->(dbSkip())
		Loop
    EndIF
	
	//-- Obtem Qtde de Marcacoes
	nLenMarc:=Len(aMarcacoes)

	aItens := {}

	// 1 - Data
	// 2 - Codigo do Evento
	// 3 - Descricao do Evento
	// 4 - Quantidade de horas Abonadas
	// 5 - Marcacoes

	dRef:=CTOD("  /  /  ")

	dbSelectArea( "SPC" )
	If DbSeek(SRA->RA_FILIAL + SRA->RA_Mat )
		While !Eof() .And. SPC->PC_FILIAL+SPC->PC_Mat == SRA->RA_FILIAL+SRA->RA_Mat

			//��������������������������������������������������������������Ŀ
			//� Consiste controle de acessos e filiais validas               �
			//����������������������������������������������������������������
			If SPC->( !Eval(cAcessaSPC) )
				SPC->(dbSkip())
				Loop
			EndIf

			//-- Verifica o Periodo Solicitado
			If Empty(SPC->PC_DATA) .OR. SPC->PC_DATA < dInicio .OR. SPC->PC_DATA > dFim
				DbSkip()
				Loop
			Endif

			If dRef != SPC->PC_DATA
				dRef       := SPC->PC_DATA
				aAutorizado := {}
				If Ascan(aTabCalend,{ |x| DtoS(x[1]) == DtoS(dRef) }) > 0
					If SP4->( dbSeek( ( cFilSP4 := xFilial('SP4', SRA->RA_FILIAL) ) + ( cTno := SRA->RA_TNOTRAB ) ) ) .Or. ;
						SP4->( dbSeek( ( cFilSP4 := xFilial('SP4', SRA->RA_FILIAL) ) + ( cTno := Space(3)        ) ) )
						Do While !SP4->(Eof()) .And. cFilSP4 + cTno == SP4->P4_FILIAL + SP4->P4_TURNO	 
							If nTipHoras == 1
								Aadd(aAutorizado,{SP4->P4_CODAUT,If(SP9->(dbSeek(fFilFunc('SP9')+SP4->P4_CODAUT)),SP9->P9_DESC,Space(20))})
							ElseIf nTipHoras == 2
								Aadd(aAutorizado,{SP4->P4_CODNAUT,If(SP9->(DbSeek(fFilFunc('SP9')+SP4->P4_CODNAUT)),SP9->P9_DESC,Space(20))})
							ElseIf nTipHoras == 3	 
								Aadd(aAutorizado,{SP4->P4_CODAUT,If(SP9->(dbSeek(fFilFunc('SP9')+SP4->P4_CODAUT)),SP9->P9_DESC,Space(20))})
								Aadd(aAutorizado,{SP4->P4_CODNAUT,If(SP9->(DbSeek(fFilFunc('SP9')+SP4->P4_CODNAUT)),SP9->P9_DESC,Space(20))})
							Endif	 
							SP4->(dbSkip())
						Enddo
					Endif    
					If nTipHoras <> 2
   						cCod029A := PosSP9("029A",SRA->RA_FILIAL,"P9_IDPON",2)
   						If !Empty(cCod029A)
							Aadd(aAutorizado,{SP9->P9_CODIGO,SP9->P9_DESC})
						Endif
						cCod025A := PosSP9("025A",SRA->RA_FILIAL,"P9_IDPON",2)
   						If !Empty(cCod025A)
							Aadd(aAutorizado,{SP9->P9_CODIGO,SP9->P9_DESC})
						Endif	
					Endif 
				Endif
			Endif

			//-- Quando houver codigo informado, este sera utilizado
			//-- em substituicao ao codigo apontado
			cPD := If(Empty(SPC->PC_PDI),SPC->PC_PD, SPC->PC_PDI)
			
			//-- Verifica se eh um codigo contido na relacao de codigos 
			//-- definidas segundo avariavel cCodigos
			nPos := Ascan(aAutorizado,{ |x| x[1] = cPD })
            //-- Se o Codigo do Evento apontado  eh Valido
			If nPos > 0
				//-- Obtem a quantidade do evento apontando
				xQuant := If(SPC->PC_QUANTI>0,SPC->PC_QUANTI,SPC->PC_QUANTC)
                //-- Posiciona na TabCalend para a Data Lida
                nTab := aScan(aTabCalend, {|x| x[CALEND_POS_DATA] == SPC->PC_DATA .And. x[CALEND_POS_TIPO_MARC] == '1E' })
			   
				//-- Se existir calendario para o apontamento
				//-- Obs.: Se um apontamento for digitado pode ocorrer de nao ter
				//--       uma data correspondente na TabCalend ???
				If nTab>0
			  	   //-- Obtem a Ordem para a Data Lida
			  	   cOrdem    := aTabCalend[nTab,CALEND_POS_ORDEM] //-- Ordem
				
				   aMarcFun:={}
				   //�����������������������������������������������Ŀ
				   //�Obtem as Marcacoes Realizadas para a Ordem Lida�
				   //�������������������������������������������������
			       If lImpMar
						//-- o Arquivo � setado para a 1a Marca��o do dia em quest�o.
						//-- de acordo com a ordem da tabela
						nPosMarc:=Ascan(aMarcacoes,{|x| x[3]==cOrdem})
						//-- Se Existir Marcacao para o Dia
						If !Empty(nPosMarc)
							//--  Corre Todas as marcacoes enquanto a mesma ordem
							While cOrdem == aMarcacoes[nPosMarc,3]
								  //-- Monta o array com as Marcacoes do funcionario para a ordem.
								  Aadd(aMarcFun,StrTran(StrZero(aMarcacoes[nPosMarc,2],5,2),'.',':'))
								  nPosMarc++
						 		  //-- Se o contador ultrapassar o total de Marcacoes abandona loop
						 		  If nPosMarc>nLenMarc
						 			 Exit
						 		  Endif   
							EndDo
					    Endif
				   Endif
			   
				Endif 
				
				
				If nSinAna == 1	// Sintetica
					If (nPosDet:=Ascan(aItens,{ |x| x[2] =  cPD })) > 0
						aItens[nPosDet,4]:=SomaHoras(aItens[nPosDet,4],xQuant)
					Else
						aAdd(aItens,{ SPC->PC_DATA, aAutorizado[nPos,1], aAutorizado[nPos,2] ,	xQuant, aMarcFun })	
					Endif			
				Else
					aAdd(aItens,{ SPC->PC_DATA, aAutorizado[nPos,1], aAutorizado[nPos,2] , xQuant, aMarcFun })	
				Endif
			Endif
			DbSkip()
		EndDo

		If Len(aItens) > 0
			aSort(aItens,,,{|x,y| x[1] < y[1] })
			
			//Vinicius Schwartz - TI - Midori Atlantica - 07/08/2012            
			//Filtro para ser impresso somente os casos onde ultrapassa o horario de risco (acima de 2 horas)
            //Inicio de manutencao
			aBIt := ACLONE(aItens)
			For nFor := 1 to Len(aBIt)
				if aBIt[nFor,4] <= 2                            
					nPos := aScan(aItens, { |x| x[4] == aBIt[nFor,4]})
					aDel(aItens,nPos) 
					aSize(aItens,Len(aItens)-1)
				endif
			next nFor
            //Fim da manutencao
            
			For nFor := 1 To Len(aItens)
				cDet :=""
				cDet2:=""	// Impressao da Continuacao das Marcacoes

				If lImpMar .And. nSinAna == 2 .And. dDtMarc<>aItens[nFor,1]
					aMarc  :=aItens[nFor,5]
					dDtMarc:=aItens[nFor,1]
					For nMar:=1 to Len(aMarc)
						If nMar > 8
							cDet2+=aMarc[nMar]+" "
						Else
							cDet+=aMarc[nMar]+" "
						Endif					
					Next
				Endif
				cDet :=Padr(cDet,49)
				cDet2:=Padr(cDet2,49)
			    
//		 		alert ('Quant antes: |'+ cValToChar(aItens[nFor,4]) +'|')
				xQuant := StrZero(aItens[nFor,4],6,2)
				xQuant := STRTRAN(xQuant,".",":")   
//				Alert ('xQuant: |' + xQuant+'|')
//				if xQuant > '002:00'
					cDet += If(nSinAna == 1,Space(5),SubStr(Dtos(aItens[nFor,1]),7,2)+'/'+SubStr(Dtos(aItens[nFor,1]),5,2)) + "  " + aItens[nFor,2] + " " + aItens[nFor,3] + " "+ xquant + " "
    			
					cDet+= Space(5) + Repl("_",20)
					If Li <> 60 .And. nFor > 1
						Impr(" ","C")
					Endif
	
					U_F060ImprL(cDet, Nil, nFor)
	
					If !Empty(cDet2)
						U_F060ImprL(cDet2,.F., nFor)
					Endif
//              endif
			Next nFor

			If Li <> 60
				Impr(Repl("-",132),"C")
			Endif

			If lImpFol
				Impr("","P")
				lCabec:=.T.
			Endif
		Endif
	Endif
	DbSelectArea("SRA")
	DbSkip()
Enddo

//��������������������������������������������������������������Ŀ
//� Termino do relatorio                                         �
//����������������������������������������������������������������
dbSelectArea( "SP8" )
dbSetOrder(1)

dbSelectArea("SRA")
dbSetOrder(1)
Set Device To Screen
If aReturn[5] = 1
	Set Printer To
	Commit
	ourspool(wnrel)
Endif
MS_FLUSH()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Imp_Cabec � Autor � J.Ricardo             � Data � 09/04/96 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do Relatorio de Presentes/Ausentes     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � POR030IMP                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
====================================================================================================
Chapa Matr.  Funcionario                    Data   Cod Descricao            Horas              Visto"
====================================================================================================
Filial: 01-123456789012345  Turno: 001-12345678901234567890    C.C: 123456789-1234567890123456789012
====================================================================================================
12345 123456 123456789012345678901234567890
99:99 99:99 99:99 99:99 99:99 99:99 99:99   99/99  999 1234567890123456789 999.99 12345678901234567890123456789 12345678901234567890
/*/
Static Function Imp_Cabec
Local  cDet
cDet := STR0017 + SRA->RA_FILIAL + "-" + Left(SM0->M0_Nome+Space(15),15) //"Filial: "

Li   := 0

If lImpFol
	cDet+= STR0018+SRA->RA_TNOTRAB // " Turno: "
	cDet+= STR0019+SUBS(SRA->RA_CC+SPACE(20),1,20) + "-" +; // "    C.C: "
	Left(DescCc(SRA->RA_CC,SRA->RA_FILIAL,30)+Space(30),30)
Endif

IMPR(cDet,"C")
IMPR(Repl("=",132),"")
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �f060ImprL � Autor � Aldo Marini Junior    � Data � 30/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime detalhe verificando a necessidade de pulo de pagina���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �f060ImprL(cString)                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � PONR010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function f060ImprL(cString,lImpNome, nFor)

Local cNome:=SRA->RA_CHAPA + " " + SRA->RA_MAT + " " + Left(SRA->RA_NOME,30) + " "
Local lCab := .F.
lImpNome := If(lImpNome==Nil,.T.,lImpNome) //-- Define se deve ou nao observar a necessidade de impressao do nome

// Caso seja primeira linha do Detalhe , imprime o Nome do Func.
If nFor == 1 .Or. Li == 60 .Or. Li == 8
	If Li == 60
		lCabec:=.T.

		If !lImpFol
			If nOrdem == 2 .Or. nOrdem == 5
				lCabecCC:=.T.
			Endif

			If nOrdem = 4
				lCabecTT := .T.
			Endif
		Endif
	Endif

	If lImpMar .And. nSinAna == 2
		lCab:=.T.
	Else
		// 45 / 49
		cString := SubStr(cString,50,Len(cString)-49)
		cString := cNome+Space(05)+cString
	Endif
Endif

If lCabec
	Imp_Cabec()
	lCabec := .F.
Endif

If lCabecCC
	cDet1 := STR0015 + SUBS(SRA->RA_CC+SPACE(20),1,20) + "-" +; // "C.C: "
	Left(DescCc(SRA->RA_CC,SRA->RA_FILIAL,30)+Space(30),30)
	IMPR(cDet1,"C")
	If Li <> 60
		IMPR(REPLICATE("-",132),"C")
	Endif
	lCabecCC := .F.
Endif

If lCabecTT
	cDet1 := STR0018+SRA->RA_TNOTRAB +"-"+ fDescTno(SRA->RA_FILIAL,SRA->RA_TNOTRAB) // " Turno: "
	IMPR(cDet1,"C")
	If Li <> 60
		IMPR(REPLICATE("-",132),"C")
	Endif
	lCabecTT := .F.
Endif

If Li < 60
	If lCab .And. lImpNome
		IMPR(cNome,"C")
		lCab:=.F.
	Endif
Endif

If Li == 60
	Imp_Cabec()
	If (nOrdem == 2 .Or. nOrdem == 5).And. !lImpFol
		cDet1 := STR0015 + SUBS(SRA->RA_CC+SPACE(20),1,20) + "-" +; // "C.C: "
		Left(DescCc(SRA->RA_CC,SRA->RA_FILIAL,30)+Space(30),30)
		IMPR(cDet1,"C")
		IMPR(REPLICATE("-",132),"C")
	Endif

	If nOrdem == 4 .And. !lImpFol
		cDet1 := STR0018+SRA->RA_TNOTRAB +"-"+ fDescTno(SRA->RA_FILIAL,SRA->RA_TNOTRAB) // " Turno: "
		IMPR(cDet1,"C")
		If Li <> 60
			IMPR(REPLICATE("-",132),"C")
		Endif
	Endif

	If lImpMar .And. nSinAna == 2
		IMPR(cNome,"C")
	Else
		cString := SubStr(cString,50,Len(cString)-49)
		cString := cNome+Space(05)+cString
	Endif	
Endif

IMPR(cString,"C")

Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � fChkSX1  � Autor � Marinaldo de Jesus    � Data �13/02/2002�
�����������������������������������������������������������������������Ĵ
�Descri��o � Verifica se os Parametros de Periodo estao corretos        �
�����������������������������������������������������������������������Ĵ
� Uso      � PONM040                                                    �
�������������������������������������������������������������������������*/
Static Function fChkSX1( dPerIni , dPerFim , cPerg )

Local aAreaSX1	:= SX1->( GetArea() )
Local dVar      := Ctod("//")

SX1->(dbSetOrder(1))

IF SX1->(dbSeek(cPerg+"14",.F.))
	dVar := Ctod(SX1->X1_CNT01,'ddmmyy')
	IF dVar < dPerIni .or. dVar > dPerFim
		RecLock("SX1")
		SX1->X1_CNT01 := Dtoc(dPerIni)
		SX1->( MsUnlock() )
	EndIF
	SX1->( dbSkip() )
	IF SX1->( X1_GRUPO + X1_ORDEM ) == cPerg+"15"
		dVar := Ctod(SX1->X1_CNT01,'ddmmyy')
		IF dVar < dPerIni .Or. dVar > dPerFim
			RecLock("SX1")
			SX1->X1_CNT01 := Dtoc(dPerFim)
			SX1->( MsUnlock() )
		EndIF
	EndIF
EndIF

RestArea( aAreaSX1 )

Return( NIL )