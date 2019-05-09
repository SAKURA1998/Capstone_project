# Capstone_project
This is the capstone project for 2019 JI summer semester, regarding acoustic tracking

--hardware:  所有已经购买的可能用的上的硬件。还有些目前看来用不上的没有放上去，可以到实验室（密院楼212-2）直接看看都有啥

--software:  主要包含一个LLAP的安卓版apk，一组生成和解调barkercode（用于估测信道参数的训练序列）的matlab代码，一组生成audio_pulse的代码，以及里面有个STFT（short term Fourier transform）的代码可以直接用

--paper:     几篇有用的论文

--materials: 毕设的proposal文档还有发票之类

第一周主要有四个活儿：

第一个是要有人认真看一遍Paper文件夹里的Vskin那篇论文（我看过了orz）,梳理出来详细的tracking流程，至少知道每一步为啥这么做就行了。可能需要两三天时间

第二个是要有人把硬件平台搭起来。东西都买好了，也不需要什么嵌入式编程，就照着hardware文件夹里的硬件连接示意图，把东西焊接起来就好。主要问题在于买到的麦克风标称的接受频率大多数在20-10khz之间，而我们需要17-22khzzz左右的声波，因此要测试一下买到的这些麦克风能不能收到这个频段的声波。这个活儿目测也要两三天时间。

第三个是需要有人康康matlab实时信号处理是怎么回事，比如一个持续的音频流输入，动态的显示这个音频流的频谱图。这个估计一两天就搞定了

第四个是可能的第一周的一些TC的活儿，一两天应该也能搞定。
