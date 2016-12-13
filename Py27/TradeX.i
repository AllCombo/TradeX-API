
%module TradeX

%include <windows.i>

%{
#include "TradeX.h"
%}

%include "cstring.i"

%cstring_bounded_output(char *pszResult, 64*1024);
%cstring_bounded_output(char *pszErrInfo, 256);

//
// 1 - 打开TDX
//

void OpenTdx();

//
// 2 - 关闭TDX
//

void CloseTdx();

//
// 3 - 登录帐号
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
// 4 - 注销
//

void Logoff(int nClientID);

//
// 5 - 查询各类交易数据
//

void QueryData(
    int nClientID,
    int nCategory,
    char* pszResult,
    char* pszErrInfo);

//
// 6 - 单账户批量查询各类交易数据
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
// 7 - 查询各类历史数据
//

void QueryHistoryData(
    int nClientID,
    int nCategory,
    const char* pszStartDate,
    const char* pszEndDate,
    char* pszResult,
    char* pszErrInfo);

//
// 8 - 下单
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
// 9 - 单账户批量下单 *
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
// 10 - 撤单
//

void CancelOrder(
    int nClientID,
    const char* pszExchangeID,
    const char* pszhth,
    char* pszResult,
    char* pszErrInfo);


//
// 11 - 单账户批量撤单 *
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
// 12 - 获取五档报价
//

void GetQuote(
    int nClientID,
    const char* pszZqdm,
    char* pszResult,
    char* pszErrInfo);


//
// 13 - 单账户批量获取五档报价
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
// 14 - 融资融券账户直接还款
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
//  连接通达信行情服务器
//
// <param name="IP">服务器IP,可在券商通达信软件登录界面“通讯设置”按钮内查得</param>
// <param name="Port">服务器端口</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_Connect(
    const char *pszIP,
    short nPort,
    char *pszResult,
    char *pszErrInfo);

//
// 断开同服务器的连接
//

void TdxHq_Disconnect();

//
// 获取市场内所有证券的数量
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Result">此API执行返回后，Result内保存了返回的证券数量</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetSecurityCount(
    char nMarket,
    short *OUTPUT, // - nCount
    char *pszErrInfo);

//
// 获取市场内某个范围内的1000支股票的股票代码
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Start">范围开始位置,第一个股票是0, 第二个是1, 依此类推,位置信息依据TdxHq_GetSecurityCount返回的证券总数确定</param>
// <param name="Count">范围的大小，API执行后,保存了实际返回的股票数目,</param>
// <param name="Result">此API执行返回后，Result内保存了返回的证券代码信息,形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetSecurityList(
    char nMarket,
    short nStart,
    short *OUTPUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// 获取证券指定范围的的K线数据
//
// <param name="Category">K线种类, 0->5分钟K线    1->15分钟K线    2->30分钟K线  3->1小时K线    4->日K线  5->周K线  6->月K线  7->1分钟  8->1分钟K线  9->日K线  10->季K线  11->年K线< / param>
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Start">范围的开始位置,最后一条K线位置是0, 前一条是1, 依此类推</param>
// <param name="Count">范围的大小，API执行前,表示用户要请求的K线数目, API执行后,保存了实际返回的K线数目, 最大值800</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetSecurityBars(
    char nCategory,
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// 获取指数的指定范围内K线数据
//
// <param name="Category">K线种类, 0->5分钟K线    1->15分钟K线    2->30分钟K线  3->1小时K线    4->日K线  5->周K线  6->月K线  7->1分钟  8->1分钟K线  9->日K线  10->季K线  11->年K线< / param>
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Start">范围开始位置,最后一条K线位置是0, 前一条是1, 依此类推</param>
// <param name="Count">范围的大小，API执行前,表示用户要请求的K线数目, API执行后,保存了实际返回的K线数目,最大值800</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetIndexBars(
    char nCategory,
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// 获取分时数据
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetMinuteTimeData(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

//
// 获取历史分时数据
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Date">日期, 比如2014年1月1日为整数20140101</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetHistoryMinuteTimeData(
    char nMarket,
    const char *pszZqdm,
    int nDate,
    char *pszResult,
    char *pszErrInfo);

//
// 获取分时成交某个范围内的数据
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Start">范围开始位置,最后一条K线位置是0, 前一条是1, 依此类推</param>
// <param name="Count">范围大小，API执行前,表示用户要请求的K线数目, API执行后,保存了实际返回的K线数目</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetTransactionData(
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    char *pszResult,
    char *pszErrInfo);

//
// 获取历史分时成交某个范围内的数据
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Start">范围开始位置,最后一条K线位置是0, 前一条是1, 依此类推</param>
// <param name="Count">范围大小，API执行前,表示用户要请求的K线数目, API执行后,保存了实际返回的K线数目</param>
// <param name="Date">日期, 比如2014年1月1日为整数20140101</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetHistoryTransactionData(
    char nMarket,
    const char *pszZqdm,
    short nStart,
    short *INOUT, // - nCount
    int date,
    char *pszResult,
    char *pszErrInfo);

//
// 批量获取多个证券的五档报价数据
//
// <param name="Market">市场代码,   0->深圳     1->上海, 第i个元素表示第i个证券的市场代码</param>
// <param name="Zqdm">证券代码, Count个证券代码组成的数组</param>
// <param name="Count">API执行前,表示用户要请求的证券数目,最大50(不同券商可能不一样,具体数目请自行咨询券商或测试), API执行后,保存了实际返回的数目</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

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
// 获取F10资料的分类
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据, 形式为表格数据，行数据之间通过\n字符分割，列数据之间通过\t分隔。一般要分配1024*1024字节的空间。出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetCompanyInfoCategory(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

//
// 获取F10资料的某一分类的内容
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="FileName">类目的文件名, 由TdxHq_GetCompanyInfoCategory返回信息中获取</param>
// <param name="Start">类目的开始位置, 由TdxHq_GetCompanyInfoCategory返回信息中获取</param>
// <param name="Length">类目的长度, 由TdxHq_GetCompanyInfoCategory返回信息中获取</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据,出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetCompanyInfoContent(
    char nMarket,
    const char *pszZqdm,
    const char *pszFileName,
    int nStart,
    int nLength,
    char *pszResult,
    char *pszErrInfo);

//
// 获取除权除息信息
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据,出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetXDXRInfo(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

//
// 获取财务信息
//
// <param name="Market">市场代码,   0->深圳     1->上海</param>
// <param name="Zqdm">证券代码</param>
// <param name="Result">此API执行返回后，Result内保存了返回的查询数据,出错时为空字符串。</param>
// <param name="ErrInfo">此API执行返回后，如果出错，保存了错误信息说明。一般要分配256字节的空间。没出错时为空字符串。</param>
// <returns>成功返货true, 失败返回false</returns>

bool TdxHq_GetFinanceInfo(
    char nMarket,
    const char *pszZqdm,
    char *pszResult,
    char *pszErrInfo);

