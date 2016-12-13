
%module TradeX

%include <windows.i>

%{
#include "TradeX.h"
%}

%include "cstring.i"

%cstring_bounded_output(char *pszResult, 64*1024);
%cstring_bounded_output(char *pszErrInfo, 256);

//
// 1 - ��TDX
//

void OpenTdx();

//
// 2 - �ر�TDX
//

void CloseTdx();

//
// 3 - ��¼�ʺ�
//


int Logon(
    const char* pszIP,
    short nPort,
    const char* pszVersion,
    short nYybID,
    const char* pszAccountNo,
    const char* pszTradeAccount,
    const char* pszJyPassword,
    const char* pszTxPassword,
    char* pszErrInfo);

//
// 4 - ע��
//

void Logoff(int nClientID);

//
// 5 - ��ѯ���ཻ������
//

void QueryData(
    int nClientID,
    int nCategory,
    char* pszResult,
    char* pszErrInfo);

//
// 6 - ���˻�������ѯ���ཻ������
//

%typemap(in) (int *nCategory, int nCount, char **pszResult, char **pszErrInfo) {
  /* Check if is a list */
  if (PyList_Check($input)) {
    int i;

    $2 = PyList_Size($input);
    $1 = (int *)malloc(($2+1)*sizeof(int));
    for (i=0; i<$2; i++)
    {
      PyObject *o = PyList_GetItem($input,i);
      if (PyInt_Check(o))
        $1[i] = PyInt_AsLong(PyList_GetItem($input,i));
      else {
        PyErr_SetString(PyExc_TypeError,"list must contain integers");
        free($1);
        return NULL;
      }
    }

    $3 = (char **) malloc(($2+1)*sizeof(char *));
    for (i = 0; i < $2; i++) {
      $3[i] = (char *)malloc(64*1024);
      if (!$3[i]) {
        for (int k=0; k<i; ++k)
	  free($3[k]);
        PyErr_SetString(PyExc_TypeError,"memory alloc error !");
        free($3);
        return NULL;
      }
    }
    $3[i] = 0;

    $4 = (char **) malloc(($2+1)*sizeof(char *));
    for (i = 0; i < $2; i++) {
      $4[i] = (char *)malloc(256);
      if (!$4[i]) {
        for (int k=0; k<i; ++k)
	  free($4[k]);
        PyErr_SetString(PyExc_TypeError,"memory alloc error !");
        free($4);

	for (int j=0; j<$2; j++)
	  free($3[j]);
        free($3);
	return NULL;
      }
    }
    $4[i] = 0;

  } else {
    PyErr_SetString(PyExc_TypeError,"not a list");
    return NULL;
  }
}

%typemap(freearg) (int *nCategory, int nCount, char **pszResult, char **pszErrInfo) {

  int i;
  free((char *) $1);

  for (i=0; i<$2; i++)
    free($3[i]);
  free((char *) $3);

  for (i=0; i<$2; i++)
    free($4[i]);
  free((char *) $4);
}

%typemap(argout) (int *nCategory, int nCount, char **pszResult, char **pszErrInfo) {

  //
  //

  int i;
  PyObject *oResult, *oErrInfo;

  oResult = PyTuple_New($2);
  for (i=0; i<$2; i++)
  {
    PyObject *o = PyString_FromString($3[i]);
    PyTuple_SetItem(oResult, i, o);
  }

  oErrInfo = PyTuple_New($2);
  for (i=0; i<$2; i++)
  {
    PyObject *o = PyString_FromString($4[i]);
    PyTuple_SetItem(oErrInfo, i, o);
  }

  PyObject *res = PyTuple_New(2);

  PyTuple_SetItem(res, 0, oResult);
  PyTuple_SetItem(res, 1, oErrInfo);

  //Py_DECREF(oResult);
  //Py_DECREF(oErrInfo);
 
  //
  //

  PyObject *o2;

  if ((!$result) || ($result == Py_None)) {
    $result = res;
  } else {
    if (!PyTuple_Check($result)) {
      PyObject *o = $result;
      $result = PyTuple_New(1);
      PyTuple_SetItem($result, 0, o);
    }

    o2 = $result;
    $result = PySequence_Concat(o2, res);

    //Py_DECREF(o2);
    //Py_DECREF(res);
  }
}

void QueryDatas(
    int nClientID,
    int *nCategory,
    int nCount,
    char** pszResult,
    char** pszErrInfo);

//
// 7 - ��ѯ������ʷ����
//

void QueryHistoryData(
    int nClientID,
    int nCategory,
    const char* pszStartDate,
    const char* pszEndDate,
    char* pszResult,
    char* pszErrInfo);

//
// 8 - �µ�
//

void SendOrder(
    int nClientID,
    int nCategory,
    int nPriceType,
    const char* pszGddm,
    const char* pszZqdm,
    float fPrice,
    int nQuantity,
    char* pszResult,
    char* pszErrInfo);

//
// 9 - ���˻������µ� *
//

/*
[ [ 0, 1, 'aaa', '600600'', 7.2, 100 ], [ ... ] ]
*/

void SendOrders(
    int nClientID,
    int *nCategory,
    int *nPriceType,
    const char** pszGddm,
    const char** pszZqdm,
    float *fPrice,
    int *nQuantity,
    int nCount,
    char** pszResult,
    char** pszErrInfo);


//
// 10 - ����
//

void CancelOrder(
    int nClientID,
    const char* pszExchangeID,
    const char* pszhth,
    char* pszResult,
    char* pszErrInfo);


//
// 11 - ���˻��������� *
//

/*
[ [ 0, '123' ], [ 1 , '111' ] ]
*/

/*
%typemap(in) (const char** pszExchangeID, const char** pszhth, int nCount, char **pszResult, char **pszErrInfo) {

  if (PyList_Check($input)) {
    int i;

    $3 = PyList_Size($input);

    $1 = (char **)malloc(($3+1)*sizeof(char *));
    for (i=0; i<$3; i++)
    {
      PyObject *o = PyList_GetItem($input, i);
      if (PyString_Check(o))
        $1[i] = PyString_AsString(PyList_GetItem($input, i));
      else {
        PyErr_SetString(PyExc_TypeError, "list must contain strings");
        free($1);
        return NULL;
      }
    }

    $2 = (char **)malloc(($3+1)*sizeof(char *));
    for (i=0; i<$3; i++)
    {
      PyObject *o = PyList_GetItem($input, i);
      if (PyString_Check(o))
        $1[i] = PyString_AsString(PyList_GetItem($input, i));
      else {
        PyErr_SetString(PyExc_TypeError, "list must contain strings");
        free($1);
        return NULL;
      }
    }

    $4 = (char **) malloc(($3+1)*sizeof(char *));
    for (i = 0; i < $3; i++) {
      $4[i] = (char *)malloc(64*1024);
      if (!$4[i]) {
        for (int k=0; k<i; ++k)
	  free($4[k]);
        PyErr_SetString(PyExc_TypeError,"memory alloc error !");
        free($4);
        return NULL;
      }
    }
    $4[i] = 0;

    $5 = (char **) malloc(($3+1)*sizeof(char *));
    for (i = 0; i < $3; i++) {
      $5[i] = (char *)malloc(256);
      if (!$5[i]) {
        for (int k=0; k<i; ++k)
	  free($5[k]);
        PyErr_SetString(PyExc_TypeError,"memory alloc error !");
        free($5);

	for (int j=0; j<$3; j++)
	  free($4[j]);
        free($4);
	return NULL;
      }
    }
    $5[i] = 0;

  } else {
    PyErr_SetString(PyExc_TypeError,"not a list");
    return NULL;
  }
}

%typemap(freearg) (const char** pszZqdm, int nCount, char **pszResult, char **pszErrInfo) {

  int i;
  free((char *) $1);

  for (i=0; i<$3; i++)
    free($4[i]);
  free((char *) $4);

  for (i=0; i<$3; i++)
    free($5[i]);
  free((char *) $5);
}

%typemap(argout) (const char** pszZqdm, int nCount, char **pszResult, char **pszErrInfo) {

  //
  //

  int i;
  PyObject *oResult, *oErrInfo;

  oResult = PyTuple_New($3);
  for (i=0; i<$3; i++)
  {
    PyObject *o = PyString_FromString($4[i]);
    PyTuple_SetItem(oResult, i, o);
  }

  oErrInfo = PyTuple_New($3);
  for (i=0; i<$3; i++)
  {
    PyObject *o = PyString_FromString($5[i]);
    PyTuple_SetItem(oErrInfo, i, o);
  }

  PyObject *res = PyTuple_New(2);

  PyTuple_SetItem(res, 0, oResult);
  PyTuple_SetItem(res, 1, oErrInfo);

  //Py_DECREF(oResult);
  //Py_DECREF(oErrInfo);
 
  //
  //

  PyObject *o2;

  if ((!$result) || ($result == Py_None)) {
    $result = res;
  } else {
    if (!PyTuple_Check($result)) {
      PyObject *o = $result;
      $result = PyTuple_New(1);
      PyTuple_SetItem($result, 0, o);
    }

    o2 = $result;
    $result = PySequence_Concat(o2, res);

    //Py_DECREF(o2);
    //Py_DECREF(res);
  }
}
*/

void CancelOrders(
    int nClientID,
    const char** pszExchangeID,
    const char** pszhth,
    int nCount,
    char** pszResult,
    char** pszErrInfo);


//
// 12 - ��ȡ�嵵����
//

void GetQuote(
    int nClientID,
    const char* pszZqdm,
    char* pszResult,
    char* pszErrInfo);


//
// 13 - ���˻�������ȡ�嵵����
//

/*
[ '600600', '000001', '601928' ]
*/

%typemap(in) (const char** pszZqdm, int nCount, char **pszResult, char **pszErrInfo) {
  /* Check if is a list */
  if (PyList_Check($input)) {
    int i;

    $2 = PyList_Size($input);
    $1 = (char **)malloc(($2+1)*sizeof(char *));
    for (i=0; i<$2; i++)
    {
      PyObject *o = PyList_GetItem($input, i);
      if (PyString_Check(o))
        $1[i] = PyString_AsString(PyList_GetItem($input, i));
      else {
        PyErr_SetString(PyExc_TypeError, "list must contain strings");
        free($1);
        return NULL;
      }
    }

    $3 = (char **) malloc(($2+1)*sizeof(char *));
    for (i = 0; i < $2; i++) {
      $3[i] = (char *)malloc(64*1024);
      if (!$3[i]) {
        for (int k=0; k<i; ++k)
	  free($3[k]);
        PyErr_SetString(PyExc_TypeError,"memory alloc error !");
        free($3);
        return NULL;
      }
    }
    $3[i] = 0;

    $4 = (char **) malloc(($2+1)*sizeof(char *));
    for (i = 0; i < $2; i++) {
      $4[i] = (char *)malloc(256);
      if (!$4[i]) {
        for (int k=0; k<i; ++k)
	  free($4[k]);
        PyErr_SetString(PyExc_TypeError,"memory alloc error !");
        free($4);

	for (int j=0; j<$2; j++)
	  free($3[j]);
        free($3);
	return NULL;
      }
    }
    $4[i] = 0;

  } else {
    PyErr_SetString(PyExc_TypeError,"not a list");
    return NULL;
  }
}

%typemap(freearg) (const char** pszZqdm, int nCount, char **pszResult, char **pszErrInfo) {

  int i;
  free((char *) $1);

  for (i=0; i<$2; i++)
    free($3[i]);
  free((char *) $3);

  for (i=0; i<$2; i++)
    free($4[i]);
  free((char *) $4);
}

%typemap(argout) (const char** pszZqdm, int nCount, char **pszResult, char **pszErrInfo) {

  //
  //

  int i;
  PyObject *oResult, *oErrInfo;

  oResult = PyTuple_New($2);
  for (i=0; i<$2; i++)
  {
    PyObject *o = PyString_FromString($3[i]);
    PyTuple_SetItem(oResult, i, o);
  }

  oErrInfo = PyTuple_New($2);
  for (i=0; i<$2; i++)
  {
    PyObject *o = PyString_FromString($4[i]);
    PyTuple_SetItem(oErrInfo, i, o);
  }

  PyObject *res = PyTuple_New(2);

  PyTuple_SetItem(res, 0, oResult);
  PyTuple_SetItem(res, 1, oErrInfo);

  //Py_DECREF(oResult);
  //Py_DECREF(oErrInfo);
 
  //
  //

  PyObject *o2;

  if ((!$result) || ($result == Py_None)) {
    $result = res;
  } else {
    if (!PyTuple_Check($result)) {
      PyObject *o = $result;
      $result = PyTuple_New(1);
      PyTuple_SetItem($result, 0, o);
    }

    o2 = $result;
    $result = PySequence_Concat(o2, res);

    //Py_DECREF(o2);
    //Py_DECREF(res);
  }
}

void GetQuotes(
    int nClientID,
    const char** pszZqdm,
    int nCount,
    char** pszResult,
    char** pszErrInfo);

//
// 14 - ������ȯ�˻�ֱ�ӻ���
//

void Repay(
    int nClientID,
    const char* pszAmount,
    char* pszResult,
    char* pszErrInfo);

//
//
//

//bool LicenseInfo(char* pszErrInfo); // License-Info


%include "typemaps.i"


//
//  ����ͨ�������������
//
// <param name="IP">������IP,����ȯ��ͨ���������¼���桰ͨѶ���á���ť�ڲ��</param>
// <param name="Port">�������˿�</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_Connect(
    const char *pszIP,
    short nPort,
    char *pszResult,
    char *pszErrInfo);

//
// �Ͽ�ͬ������������
//

void TdxHq_Disconnect();

//
// ��ȡ�г�������֤ȯ������
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��ص�֤ȯ����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetSecurityCount(
    char nMarket,
    short *OUTPUT, // - nCount
    char *pszErrInfo);

//
// ��ȡ�г���ĳ����Χ�ڵ�1000֧��Ʊ�Ĺ�Ʊ����
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Start">��Χ��ʼλ��,��һ����Ʊ��0, �ڶ�����1, ��������,λ����Ϣ����TdxHq_GetSecurityCount���ص�֤ȯ����ȷ��</param>
// <param name="Count">��Χ�Ĵ�С��APIִ�к�,������ʵ�ʷ��صĹ�Ʊ��Ŀ,</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��ص�֤ȯ������Ϣ,��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetSecurityList(
    char nMarket,
    short nStart,
    short *OUTPUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ֤ȯָ����Χ�ĵ�K������
//
// <param name="Category">K������, 0->5����K��    1->15����K��    2->30����K��  3->1СʱK��    4->��K��  5->��K��  6->��K��  7->1����  8->1����K��  9->��K��  10->��K��  11->��K��< / param>
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Start">��Χ�Ŀ�ʼλ��,���һ��K��λ����0, ǰһ����1, ��������</param>
// <param name="Count">��Χ�Ĵ�С��APIִ��ǰ,��ʾ�û�Ҫ�����K����Ŀ, APIִ�к�,������ʵ�ʷ��ص�K����Ŀ, ���ֵ800</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetSecurityBars(
    char nCategory,
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡָ����ָ����Χ��K������
//
// <param name="Category">K������, 0->5����K��    1->15����K��    2->30����K��  3->1СʱK��    4->��K��  5->��K��  6->��K��  7->1����  8->1����K��  9->��K��  10->��K��  11->��K��< / param>
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Start">��Χ��ʼλ��,���һ��K��λ����0, ǰһ����1, ��������</param>
// <param name="Count">��Χ�Ĵ�С��APIִ��ǰ,��ʾ�û�Ҫ�����K����Ŀ, APIִ�к�,������ʵ�ʷ��ص�K����Ŀ,���ֵ800</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetIndexBars(
    char nCategory,
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ��ʱ����
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetMinuteTimeData(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ��ʷ��ʱ����
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Date">����, ����2014��1��1��Ϊ����20140101</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetHistoryMinuteTimeData(
    char nMarket,
    const char *pszZqdm,
    int nDate,
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ��ʱ�ɽ�ĳ����Χ�ڵ�����
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Start">��Χ��ʼλ��,���һ��K��λ����0, ǰһ����1, ��������</param>
// <param name="Count">��Χ��С��APIִ��ǰ,��ʾ�û�Ҫ�����K����Ŀ, APIִ�к�,������ʵ�ʷ��ص�K����Ŀ</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetTransactionData(
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ��ʷ��ʱ�ɽ�ĳ����Χ�ڵ�����
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Start">��Χ��ʼλ��,���һ��K��λ����0, ǰһ����1, ��������</param>
// <param name="Count">��Χ��С��APIִ��ǰ,��ʾ�û�Ҫ�����K����Ŀ, APIִ�к�,������ʵ�ʷ��ص�K����Ŀ</param>
// <param name="Date">����, ����2014��1��1��Ϊ����20140101</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetHistoryTransactionData(
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    int date,
    char *pszResult,
    char *pszErrInfo);

//
// ������ȡ���֤ȯ���嵵��������
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�, ��i��Ԫ�ر�ʾ��i��֤ȯ���г�����</param>
// <param name="Zqdm">֤ȯ����, Count��֤ȯ������ɵ�����</param>
// <param name="Count">APIִ��ǰ,��ʾ�û�Ҫ�����֤ȯ��Ŀ,���50(��ͬȯ�̿��ܲ�һ��,������Ŀ��������ѯȯ�̻����), APIִ�к�,������ʵ�ʷ��ص���Ŀ</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

/*
{ '600600' : 1, '000001' : 0 }
*/

bool TdxHq_GetSecurityQuotes(
    char nMarket[],
    const char *pszZqdm[],
    short *nCount,
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡF10���ϵķ���
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����, ��ʽΪ������ݣ�������֮��ͨ��\n�ַ��ָ������֮��ͨ��\t�ָ���һ��Ҫ����1024*1024�ֽڵĿռ䡣����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetCompanyInfoCategory(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡF10���ϵ�ĳһ���������
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="FileName">��Ŀ���ļ���, ��TdxHq_GetCompanyInfoCategory������Ϣ�л�ȡ</param>
// <param name="Start">��Ŀ�Ŀ�ʼλ��, ��TdxHq_GetCompanyInfoCategory������Ϣ�л�ȡ</param>
// <param name="Length">��Ŀ�ĳ���, ��TdxHq_GetCompanyInfoCategory������Ϣ�л�ȡ</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����,����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetCompanyInfoContent(
    char nMarket,
    const char *pszZqdm,
    const char *pszFileName,
    int nStart,
    int nLength,
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ��Ȩ��Ϣ��Ϣ
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����,����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetXDXRInfo(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

//
// ��ȡ������Ϣ
//
// <param name="Market">�г�����,   0->����     1->�Ϻ�</param>
// <param name="Zqdm">֤ȯ����</param>
// <param name="Result">��APIִ�з��غ�Result�ڱ����˷��صĲ�ѯ����,����ʱΪ���ַ�����</param>
// <param name="ErrInfo">��APIִ�з��غ�������������˴�����Ϣ˵����һ��Ҫ����256�ֽڵĿռ䡣û����ʱΪ���ַ�����</param>
// <returns>�ɹ�����true, ʧ�ܷ���false</returns>

bool TdxHq_GetFinanceInfo(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

