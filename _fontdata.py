#Copyright ReportLab Europe Ltd. 2000-2004
#see license.txt for license details
#history http://www.reportlab.co.uk/cgi-bin/viewcvs.cgi/public/reportlab/trunk/reportlab/pdfbase/_fontdata.py
#$Header $
__version__=''' $Id: _fontdata.py 3666 2010-02-10 21:01:22Z andy $ '''
__doc__="""Database of font related things

    - standardFonts - tuple of the 14 standard string font names
    - standardEncodings - tuple of the known standard font names
    - encodings - a mapping object from standard encoding names (and minor variants)
      to the encoding vectors ie the tuple of string glyph names
    - widthsByFontGlyph - fontname x glyphname --> width of glyph
    - widthVectorsByFont - fontName -> vector of widths 
    
    This module defines a static, large data structure.  At the request
    of the Jython project, we have split this off into separate modules
    as Jython cannot handle more than 64k of bytecode in the 'top level'
    code of a Python module.  
"""
import UserDict, os, sys

# mapping of name to width vector, starts empty until fonts are added
# e.g. widths['NimbusMonoPS-Regular'] = [...600,600,600,...]
widthVectorsByFont = {}
fontsByName = {}
fontsByBaseEnc = {}
# this is a list of the standard 14 font names in Acrobat Reader
standardFonts = (
    'NimbusMonoPS-Regular', 'NimbusMonoPS-Regular-Bold', 'NimbusMonoPS-Regular-Oblique', 'NimbusMonoPS-Regular-BoldOblique',
    'NimbusSans-Regular', 'NimbusSans-Regular-Bold', 'NimbusSans-Regular-Oblique', 'NimbusSans-Regular-BoldOblique',
    'NimbusRoman-Regular', 'NimbusRoman-Bold', 'NimbusRoman-Italic', 'NimbusRoman-BoldItalic',
    'Symbol','ZapfDingbats')

standardFontAttributes = {
    #family, bold, italic defined for basic ones
    'NimbusMonoPS-Regular':('NimbusMonoPS-Regular',0,0),
    'NimbusMonoPS-Regular-Bold':('NimbusMonoPS-Regular',1,0),
    'NimbusMonoPS-Regular-Oblique':('NimbusMonoPS-Regular',0,1),
    'NimbusMonoPS-Regular-BoldOblique':('NimbusMonoPS-Regular',1,1),
    
    'NimbusSans-Regular':('NimbusSans-Regular',0,0),
    'NimbusSans-Regular-Bold':('NimbusSans-Regular',1,0),
    'NimbusSans-Regular-Oblique':('NimbusSans-Regular',0,1),
    'NimbusSans-Regular-BoldOblique':('NimbusSans-Regular',1,1),

    'NimbusRoman-Regular':('NimbusRoman-Regular',0,0),
    'NimbusRoman-Bold':('NimbusRoman-Regular',1,0),
    'NimbusRoman-Italic':('NimbusRoman-Regular',0,1),
    'NimbusRoman-BoldItalic':('NimbusRoman-Regular',1,1),

    'Symbol':('Symbol',0,0),
    'ZapfDingbats':('ZapfDingbats',0,0)

    }

#this maps fontnames to the equivalent filename root.
_font2fnrMapWin32 = {
                    'symbol':                   'sy______',
                    'zapfdingbats':             'zd______',
                    'helvetica':                '_a______',
                    'helvetica-bold':           '_ab_____',
                    'helvetica-boldoblique':    '_abi____',
                    'helvetica-oblique':        '_ai_____',
                    'times-bold':               '_eb_____',
                    'times-bolditalic':         '_ebi____',
                    'times-italic':             '_ei_____',
                    'times-roman':              '_er_____',
                    'courier-bold':             'cob_____',
                    'courier-boldoblique':      'cobo____',
                    'courier':                  'com_____',
                    'courier-oblique':          'coo_____',
                    }
if sys.platform in ('linux2',):
    _font2fnrMapLinux2 ={
                'symbol': 'Symbol',
                'zapfdingbats': 'ZapfDingbats',
                'helvetica': 'NimbusSans-Regular',
                'helvetica-bold': 'NimbusSans-Regular-Bold',
                'helvetica-boldoblique': 'NimbusSans-Regular-BoldItalic',
                'helvetica-oblique': 'NimbusSans-Regular-Italic',
                'times-bold': 'NimbusRoman-Regular-Bold',
                'times-bolditalic':'NimbusRoman-Regular-BoldItalic',
                'times-italic': 'NimbusRoman-Regular-Italic',
                'times-roman': 'NimbusRoman-Regular',
                'courier-bold': 'NimbusMonoPS-Regular-Bold',
                'courier-boldoblique': 'NimbusMonoPS-Regular-BoldOblique',
                'courier': 'NimbusMonoPS-Regular',
                'courier-oblique': 'NimbusMonoPS-Regular-Oblique',
                }
    _font2fnrMap = _font2fnrMapLinux2
    for k, v in _font2fnrMap.items():
        if k in _font2fnrMapWin32.keys():
            _font2fnrMapWin32[v.lower()] = _font2fnrMapWin32[k]
    del k, v
else:
    _font2fnrMap = _font2fnrMapWin32

def _findFNR(fontName):
    return _font2fnrMap[fontName.lower()]

from reportlab.rl_config import T1SearchPath
from reportlab.lib.utils import rl_isfile
def _searchT1Dirs(n,rl_isfile=rl_isfile,T1SearchPath=T1SearchPath):
    assert T1SearchPath!=[], "No Type-1 font search path"
    for d in T1SearchPath:
        f = os.path.join(d,n)
        if rl_isfile(f): return f
    return None
del T1SearchPath, rl_isfile

def findT1File(fontName,ext='.pfb'):
    if sys.platform in ('linux2',) and ext=='.pfb':
        try:
            f = _searchT1Dirs(_findFNR(fontName))
            if f: return f
        except:
            pass

        try:
            f = _searchT1Dirs(_font2fnrMapWin32[fontName.lower()]+ext)
            if f: return f
        except:
            pass

    return _searchT1Dirs(_findFNR(fontName)+ext)

# this lists the predefined font encodings - WinAnsi and MacRoman.  We have
# not added MacExpert - it's possible, but would complicate life and nobody
# is asking.  StandardEncoding means something special.
standardEncodings = ('WinAnsiEncoding','MacRomanEncoding','StandardEncoding','SymbolEncoding','ZapfDingbatsEncoding','PDFDocEncoding', 'MacExpertEncoding')

#this is the global mapping of standard encodings to name vectors
class _Name2StandardEncodingMap(UserDict.UserDict):
    '''Trivial fake dictionary with some [] magic'''
    _XMap = {'winansi':'WinAnsiEncoding','macroman': 'MacRomanEncoding','standard':'StandardEncoding','symbol':'SymbolEncoding', 'zapfdingbats':'ZapfDingbatsEncoding','pdfdoc':'PDFDocEncoding', 'macexpert':'MacExpertEncoding'}
    def __setitem__(self,x,v):
        y = x.lower()
        if y[-8:]=='encoding': y = y[:-8]
        y = self._XMap[y]
        if y in self.keys(): raise IndexError, 'Encoding %s is already set' % y
        self.data[y] = v

    def __getitem__(self,x):
        y = x.lower()
        if y[-8:]=='encoding': y = y[:-8]
        y = self._XMap[y]
        return self.data[y]

encodings = _Name2StandardEncodingMap()

#due to compiled method size limits in Jython,
#we pull these in from separate modules to keep this module
#well under 64k.  We might well be able to ditch many of
#these anyway now we run on Unicode.

from reportlab.pdfbase._fontdata_enc_winansi import WinAnsiEncoding
from reportlab.pdfbase._fontdata_enc_macroman import MacRomanEncoding
from reportlab.pdfbase._fontdata_enc_standard import StandardEncoding
from reportlab.pdfbase._fontdata_enc_symbol import SymbolEncoding
from reportlab.pdfbase._fontdata_enc_zapfdingbats import ZapfDingbatsEncoding
from reportlab.pdfbase._fontdata_enc_pdfdoc import PDFDocEncoding
from reportlab.pdfbase._fontdata_enc_macexpert import MacExpertEncoding
encodings.update({
    'WinAnsiEncoding': WinAnsiEncoding,
    'MacRomanEncoding': MacRomanEncoding,
    'StandardEncoding': StandardEncoding,
    'SymbolEncoding': SymbolEncoding,
    'ZapfDingbatsEncoding': ZapfDingbatsEncoding,
    'PDFDocEncoding': PDFDocEncoding,
    'MacExpertEncoding': MacExpertEncoding,
})

ascent_descent = {
    'NimbusMonoPS-Regular': (629, -157),
    'NimbusMonoPS-Regular-Bold': (626, -142),
    'NimbusMonoPS-Regular-BoldOblique': (626, -142),
    'NimbusMonoPS-Regular-Oblique': (629, -157),
    'NimbusSans-Regular': (718, -207),
    'NimbusSans-Regular-Bold': (718, -207),
    'NimbusSans-Regular-BoldOblique': (718, -207),
    'NimbusSans-Regular-Oblique': (718, -207),
    'NimbusRoman-Regular': (683, -217),
    'NimbusRoman-Bold': (676, -205),
    'NimbusRoman-BoldItalic': (699, -205),
    'NimbusRoman-Italic': (683, -205),
    'Symbol': (0, 0),
    'ZapfDingbats': (0, 0)
    }

# ditto about 64k limit - profusion of external files
import reportlab.pdfbase._fontdata_widths_courier
import reportlab.pdfbase._fontdata_widths_courierbold
import reportlab.pdfbase._fontdata_widths_courieroblique
import reportlab.pdfbase._fontdata_widths_courierboldoblique
import reportlab.pdfbase._fontdata_widths_helvetica
import reportlab.pdfbase._fontdata_widths_helveticabold
import reportlab.pdfbase._fontdata_widths_helveticaoblique
import reportlab.pdfbase._fontdata_widths_helveticaboldoblique
import reportlab.pdfbase._fontdata_widths_timesroman
import reportlab.pdfbase._fontdata_widths_timesbold
import reportlab.pdfbase._fontdata_widths_timesitalic
import reportlab.pdfbase._fontdata_widths_timesbolditalic
import reportlab.pdfbase._fontdata_widths_symbol
import reportlab.pdfbase._fontdata_widths_zapfdingbats
widthsByFontGlyph = {
    'NimbusMonoPS-Regular':
    reportlab.pdfbase._fontdata_widths_courier.widths,
    'NimbusMonoPS-Regular-Bold':
    reportlab.pdfbase._fontdata_widths_courierbold.widths,
    'NimbusMonoPS-Regular-Oblique':
    reportlab.pdfbase._fontdata_widths_courieroblique.widths,
    'NimbusMonoPS-Regular-BoldOblique':
    reportlab.pdfbase._fontdata_widths_courierboldoblique.widths,
    'NimbusSans-Regular':
    reportlab.pdfbase._fontdata_widths_helvetica.widths,
    'NimbusSans-Regular-Bold':
    reportlab.pdfbase._fontdata_widths_helveticabold.widths,
    'NimbusSans-Regular-Oblique':
    reportlab.pdfbase._fontdata_widths_helveticaoblique.widths,
    'NimbusSans-Regular-BoldOblique':
    reportlab.pdfbase._fontdata_widths_helveticaboldoblique.widths,
    'NimbusRoman-Regular':
    reportlab.pdfbase._fontdata_widths_timesroman.widths,
    'NimbusRoman-Bold':
    reportlab.pdfbase._fontdata_widths_timesbold.widths,
    'NimbusRoman-Italic':
    reportlab.pdfbase._fontdata_widths_timesitalic.widths,
    'NimbusRoman-BoldItalic':
    reportlab.pdfbase._fontdata_widths_timesbolditalic.widths,
    'Symbol':
    reportlab.pdfbase._fontdata_widths_symbol.widths,
    'ZapfDingbats':
    reportlab.pdfbase._fontdata_widths_zapfdingbats.widths,
}


#preserve the initial values here
def _reset(
        initial_dicts=dict(
            ascent_descent=ascent_descent.copy(),
            fontsByBaseEnc=fontsByBaseEnc.copy(),
            fontsByName=fontsByName.copy(),
            standardFontAttributes=standardFontAttributes.copy(),
            widthVectorsByFont=widthVectorsByFont.copy(),
            widthsByFontGlyph=widthsByFontGlyph.copy(),
            )
        ):
    for k,v in initial_dicts.iteritems():
        d=globals()[k]
        d.clear()
        d.update(v)

from reportlab.rl_config import register_reset
register_reset(_reset)
del register_reset
