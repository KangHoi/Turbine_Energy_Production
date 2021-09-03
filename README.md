# Turbine_Energy_Production

## Ⅰ. 서론
현재 우리의 삶에서 에너지는 필수적이다. 개발된 시점부터 지속적으로 발전한 가스 터빈은 에너지 생산에서 매우 중요한 위치에 있다. 본 연구에서는 터키의 북서부 지역에 위치한 가스터빈에서 수집된 정보를이용해 터빈에너지수율(TEY)을 예측하고자 한다. 사용된 데이터들은 가스터빈 센서에 의해 2011. 01. 01. ~ 2015. 12. 31. 기간 동안 1시간 씩 집계된 11개 변수의 측정값으로 이루어져 있다. 본 연구팀은 변수의 종류가 많다는 점을 고려해 더욱 정확한 예측을 위해 서포트벡터머신회귀(SVR)를활용한다. 그 후, 변수들과 결과값 간 최적화된 모델링 구축을 목표로 연구한다. 프로그램은 SVR구현이 가장 용이한 R을 활용했다.

## Ⅱ. 본론
### 1. 연구 설계
#### 1) 연구 수행 단계 도식화
![image](https://user-images.githubusercontent.com/76719920/130251785-ea357aae-dcbd-42b5-a7fd-6342dad65fc2.png)

#### 2) SVR 적용 순서
- 원문제 제시
- 제시한 원문제에 라그랑지안 승수법 적용하여 Soft Margin 도출
- 도출된 Soft Margin 사용하여 회귀식 구성
- 회귀식은 선형성만을 띄는 한계가 존재하므로 매핑 함수(Mapping Function)를 활용
- 고차원 공간으로 매핑 가능한 kernel trick을 도입하고 Linear, Radial, Sigmoid 커널 함수 이용


### 2. 연구 진행
#### 1) Data Set 소개
가스 터빈에서 1시간 동안 집계된 10개의 센서 측정 값 36733개가 시간 순으로 정렬되어 있다. 아래와 같은 값에서 터빈 에너지 생산량(TEY)을 y값으로 설정하고 나머지는 변수로 지정한다.
|센서|단위|최소|최대|평균|
|----|----|----|----|----|
|주변 온도 (AT)|℃|-6.23|37.10|17.71|
|주변 압력 (AP)|mbar|985.85|1036.56|1013.07|
|주변 습도 (AH)|(%)|24.08|100.20|77.87|
|공기 필터 압력차 (AFDP)|mbar|2.09|7.61|3.93|
|가스 터빈 배기 압력 (GTEP)|mbar|17.70|40.72|25.56|
|터빈 입구 온도 (TIT)|°C|1000.85|1100.89|1081.43|
|터빈 작동 후 온도 (TAT)|°C|511.04|550.61|546.16|
|컴프레셔 배출 압력 (CDP)|mbar|9.85|15.16|12.06|
|__터빈 에너지 생산량 (TEY)|MWH|100.02|179.50|133.51|__
|일산화탄소 (CO)|Mg/|0.00|44.10|2.37|


#### 2) 활용한 R 프로그램 패키지
- forecast: 시계열 분석 위한 패키지, ARIMA 모델 구현
- rpart: 변수 선택
- rpart.plot: 분류 분석 모델 시각화
- e1071: SVR 또는 SVM 구현

#### 3) R 프로그램 구현
**A. Linear kernel 활용**
<br>
ⅰ. kernel 적용
```
obj<- tune(svm, TEY~., data = train.df, kernel="linear", 
          ranges = list(cost=2^(0:5)),
          tunecontrol = tune.control(sampleing="fix"))
```
ⅱ. 정확성 검토
```
svm.model <- (TEY~., data=train.df, kernel="linear", cost=16)
summary(svm.model)
svm.pred <- predict(svm.model, valid.df)
accuracy(svm.pred, valid.df$TEY)
```

**B. Radial kernel 활용**
<br>
ⅰ. kernel 적용
```
obj<- tune(svm, TEY~., data = train.df, kernel="radial",
          ranges = list(gamma = 2^(-9:0), cost = 2^(0:5)),
          tunecontrol = tune.control(sampleing="fix"))
```
ⅱ. 정확성 검토
```
svm.model <- (TEY~., data=train.df, kernel="radial", gamma=0.0078125, cost=32)
summary(svm.model)
svm.pred <- predict(svm.model, valid.df)
accuracy(svm.pred, valid.df$TEY)
```

**C. Sigmoid kernel 활용**
<br>
ⅰ. kernel 적용
```
obj<- tune(svm, TEY~., data = train.df, kernel="sigmoid",
          ranges = list(gamma = 2^(-9:0), cost = 2^(0:5), czero=2^(0:5)),
          tunecontrol = tune.control(sampleing="fix"))
```
ⅱ. 정확성 검토
```
svm.model <- (TEY~., data=train.df, kernel="sigmoid", gamma=0.001953125, cost=1, coef=1)
summary(svm.model)
svm.pred <- predict(svm.model, valid.df)
accuracy(svm.pred, valid.df$TEY)
```


#### 4) R 프로그램 구현 결과

**A. Linear kernel 활용**
<br>
ⅰ. kernel 적용
- best parameters: cost 16
- best performance: 0.9024026

ⅱ. 정확성 검토
- Parameters<br>
  SVM-Type: eps-regression<br>
  SVM-Kernel: linear<br>
  cost: 16<br>
  gamma: 0.1<br>
  epsilon: 0.1<br>
  
- Number of Support Vectors: 2558
- Test set
  |ME|RMSE|MAE|MPE|MAPE|
  |--|----|---|---|----|
  |-0.07724102|0.9604588|0.7584413|-0.0654235|0.5716215|


**B. Radial kernel 활용**
<br>
ⅰ. kernel 적용
- best parameters: gamma 0.015625  cost 32
- best performance: 0.5796032

ⅱ. 정확성 검토
- Parameters<br>
  SVM-Type: eps-regression<br>
  SVM-Kernel: radial<br>
  cost: 32<br>
  gamma: 0.015625<br>
  epsilon: 0.1<br>
  
- Number of Support Vectors: 914
- Test set
  |ME|RMSE|MAE|MPE|MAPE|
  |--|----|---|---|----|
  |0.02453148|0.73241|0.5694676|0.1350609|0.4302597|
  
  
 **C. Sigmoid kernel 활용**
  <br>
ⅰ. kernel 적용
- best parameters: gamma 0.001953125  cost 1  ceof 1
- best performance: 1.216222

ⅱ. 정확성 검토
- Parameters<br>
  SVM-Type: eps-regression<br>
  SVM-Kernel: sigmoid<br>
  cost: 1<br>
  gamma: 0.001953125<br>
  ceof.0: 0<br>
  epsilon: 0.1<br>
  
- Number of Support Vectors: 3286
- Test set
  |ME|RMSE|MAE|MPE|MAPE|
  |--|----|---|---|----|
  |-0.05718305|1.102|0.8372338|-0.005865487|0.6335361|
  
  
  
## Ⅲ. 결론
### 1. kernel 적용 결과
||Best Parameters|Best Performance|
|-|--------------|----------------|
|Linear|cost: 16|0.9024026|
|Radial|gamma: 0.015625 <br> cost: 32| **0.5796032**|
|Sigmoid|gamma: 0.001953125 <br> cost: 1 <br> ceof: 1|1.216222|
  
### 2. 정확성 검토 결과
||ME|RMSE|MAE|MPE|MAPE|
|-|--|---|---|---|----|
|Linear|-0.07724102|0.9604588|0.754413|-0.0654235|0.5716215|
|Radial|0.02453146|**_0.73241_**|0.5694676|0.01350609|**_0.4302597_**|
|Sigmoid|-0.05718305|1.102|0.8372338|-0.05865487|0.6335361|

3개의 kernel을 통해 SVR 학습 결과, Radial kernel의 최적 수행 결과가 0.5796032로 최소이다. 이는 Linear kernel과 Sigmoid kernel에 비해 Radial kernel의 오류 범위가 더 적다는 것을 의미한다. 또한, 학습 데이터의 정확성 검토 결과 Radial kernel의 대푯값 중 RMSE와 MAPE의 값이 각각 0.73241, 0.4302597로 최소임을 확인할 수 있다. 결과적으로 Radial kernel을 이용 할 경우 가장 정확한 예측이 가능하다.

  
  
  
