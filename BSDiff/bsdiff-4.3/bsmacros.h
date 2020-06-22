//
//  bsmacros.h
//  BSDiff
//
//  Created by 顾海军 on 2020/6/22.
//

#ifndef bsmacros_h
#define bsmacros_h

#undef err
#define err(status, ...) \
{ \
    int _len = snprintf(NULL, 0, __VA_ARGS__); \
    *errmsg = malloc(_len); \
    snprintf(*errmsg, _len, __VA_ARGS__); \
    return status; \
}

#undef errx
#define errx(status, ...) \
{ \
    int _len = snprintf(NULL, 0, __VA_ARGS__); \
    *errmsg = malloc(_len); \
    snprintf(*errmsg, _len, __VA_ARGS__); \
    return status; \
} \

#endif /* bsmacros_h */
