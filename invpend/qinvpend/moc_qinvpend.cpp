/****************************************************************************
** Meta object code from reading C++ file 'qinvpend.h'
**
** Created: Sun Dec 6 19:03:46 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "qinvpend.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'qinvpend.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QinvPend[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      16,   10,    9,    9, 0x0a,
      42,   40,    9,    9, 0x0a,
      59,    9,    9,    9, 0x0a,
      69,    9,    9,    9, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_QinvPend[] = {
    "QinvPend\0\0x,phi\0setState(double,double)\0"
    "f\0setForce(double)\0repaint()\0nextState()\0"
};

const QMetaObject QinvPend::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_QinvPend,
      qt_meta_data_QinvPend, 0 }
};

const QMetaObject *QinvPend::metaObject() const
{
    return &staticMetaObject;
}

void *QinvPend::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QinvPend))
        return static_cast<void*>(const_cast< QinvPend*>(this));
    return QWidget::qt_metacast(_clname);
}

int QinvPend::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: setState((*reinterpret_cast< double(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2]))); break;
        case 1: setForce((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 2: repaint(); break;
        case 3: nextState(); break;
        default: ;
        }
        _id -= 4;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
