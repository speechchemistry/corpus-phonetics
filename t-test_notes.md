
By default R assumes variances are different

> t.test(t(formant1_i_normal_domain), t(formant1_i_vh_harmony))

    Welch Two Sample t-test

```
data:  t(formant1_i_normal_domain) and t(formant1_i_vh_harmony)
t = 2.3537, df = 48.838, p-value = 0.02266
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
   9.730728 123.445742
sample estimates:
mean of x mean of y
406.3382  339.7500
```

```
> t.test(t(formant1_i_normal_domain), t(formant1_i_vh_harmony), var.equal = TRUE)

    Two Sample t-test

data:  t(formant1_i_normal_domain) and t(formant1_i_vh_harmony)
t = 2.6352, df = 90, p-value = 0.009901
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
  16.38765 116.78882
sample estimates:
mean of x mean of y
406.3382  339.7500
```

*There is a significant difference in F1 between the /i/ tokens in the harmony domain and /i/ tokens in the non-harmony domain (p<0.05)*

