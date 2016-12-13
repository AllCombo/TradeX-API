"""
setup.py
"""
 
from distutils.core import setup, Extension
 
 
TradeX_module = Extension('_TradeX',
                           sources=['TradeX_wrap.cxx', ],
						   include_dirs=['../TradeX-dev'],
                           library_dirs=['../TradeX-dev'],
                           libraries=['TradeX'],
                           )
 
setup (name = 'TradeX',
       version = '0.1',
       author      = "newgu8@163.com",
       description = """TradeX-Python27-API""",
       ext_modules = [TradeX_module],
       py_modules = ["TradeX"],
	   url = "https://github.com/huichou/TradeX-API",
       )
