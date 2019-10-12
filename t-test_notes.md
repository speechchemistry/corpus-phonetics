
By default R assumes variances are different

```
> t.test(t(formant1_i_normal_domain), t(formant1_i_vh_harmony))

    Welch Two Sample t-test

data:  t(formant1_i_normal_domain) and t(formant1_i_vh_harmony)
t = 2.3537, df = 48.838, p-value = 0.02266
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
   9.730728 123.445742
sample estimates:
mean of x mean of y
406.3382  339.7500

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

**Therefore there is a significant difference in F1 between the /i/ tokens in the harmony domain and /i/ tokens not in the height harmony domain (p<0.05)**

```
> var.test(t(formant2_i_normal_domain),t(formant2_i_vh_harmony))

    F test to compare two variances

data:  t(formant2_i_normal_domain) and t(formant2_i_vh_harmony)
F = 0.56884, num df = 34, denom df = 57, p-value = 0.07976
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
0.3167503 1.0710143
sample estimates:
ratio of variances
         0.5688384

> t.test(t(formant2_i_normal_domain), t(formant2_i_vh_harmony))

    Welch Two Sample t-test

data:  t(formant2_i_normal_domain) and t(formant2_i_vh_harmony)
t = 0.92828, df = 86.401, p-value = 0.3558
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
-76.05479 209.32376
sample estimates:
mean of x mean of y
1872.100  1805.466
```

**Therefore there is no significant difference in F2 between the /i/ tokens in the harmony domain and /i/ tokens not in the height harmony domain**

For the next tests I removed the two u outliers

```
> var.test(t(formant1_u_normal_domain),t(formant1_u_vh_harmony))

    F test to compare two variances

data:  t(formant1_u_normal_domain) and t(formant1_u_vh_harmony)
F = 6.0511, num df = 29, denom df = 66, p-value = 1.518e-09
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
  3.358424 11.776827
sample estimates:
ratio of variances
          6.051148

> t.test(t(formant1_u_normal_domain),t(formant1_u_vh_harmony),var.equal = TRUE)

    Two Sample t-test

data:  t(formant1_u_normal_domain) and t(formant1_u_vh_harmony)
t = 1.5396, df = 95, p-value = 0.127
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
-8.623554 68.211614
sample estimates:
mean of x mean of y
  381.100   351.306
```

**Therefore there is no significant difference in F1 between the /u/ tokens in the harmony domain and /u/ tokens not in the height harmony domain**

```
> var.test(t(formant2_u_normal_domain),t(formant2_u_vh_harmony))

    F test to compare two variances

data:  t(formant2_u_normal_domain) and t(formant2_u_vh_harmony)
F = 1.9298, num df = 34, denom df = 65, p-value = 0.02298
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
1.094776 3.596880
sample estimates:
ratio of variances
          1.929759

> t.test(t(formant2_u_normal_domain),t(formant2_u_vh_harmony),var.equal = TRUE)

    Two Sample t-test

data:  t(formant2_u_normal_domain) and t(formant2_u_vh_harmony)
t = 2.8982, df = 99, p-value = 0.004622
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
  52.97338 282.98982
sample estimates:
mean of x mean of y
1401.929  1233.947
```

**Therefore there is a significant difference in F2 between the /u/ tokens in the harmony domain and /u/ tokens not in the height harmony domain (p<0.05)**
