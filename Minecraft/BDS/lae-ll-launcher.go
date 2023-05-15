package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	inR, inW, _ := os.Pipe()
	outR, outW, _ := os.Pipe()
	dir, _ := filepath.Abs(filepath.Dir(os.Args[0]))

	done := make(chan struct{})

	process, _ := os.StartProcess("/bin/sh", nil, &os.ProcAttr{
		Files: []*os.File{inR, outW, outW},
		Dir:   dir,
	})

	fmt.Println("由 莱云 提供技术支持。")
	fmt.Println("莱云: https://www.laecloud.com")

	// check bedrock_server_mod.exe if not exists
	if _, err := os.Stat("bedrock_server_mod.exe"); os.IsNotExist(err) {
		fmt.Println("正在初始化 LiteLoader BDS，这可能需要几分钟...")

		cmd := exec.Command("/usr/bin/wine", "LLPeEditor.exe")
		var out bytes.Buffer
		cmd.Stdout = &out
		err := cmd.Run()
		fmt.Println(out.String(), err)
	}

	go func() {
		// read console
		reader := bufio.NewReader(os.Stdin)
		writer := bufio.NewWriter(inW)

		writer.WriteString("wine bedrock_server_mod.exe\n")
		writer.Flush()

		for {
			text, _ := reader.ReadString('\n')
			inW.Write([]byte(text))
			// writer.WriteString(text)
			writer.Flush()

		}
	}()

	go func() {
		scanner := bufio.NewScanner(outR)
		text := ""
		for scanner.Scan() {
			text = scanner.Text()

			fmt.Println(text)

			// if find := strings.Contains(text, "type \"help\" or \"?\""); find {
			// 	fmt.Println("服务器启动成功，现在可以进入服务器了！")
			// 	break
			// }

			// if find := strings.Contains(text, "Quit correctly"); find {
			// 	// fmt.Println("服务器已正常关闭。")
			// 	break
			// }

		}
		process.Signal(os.Kill)
		done <- struct{}{}
		fmt.Println("进程结束。")
	}()

	process.Wait()

	// buffer := new(bytes.Buffer)
	// buffer.ReadFrom(outR)
	// fmt.Println(buffer.String())

	os.Exit(0)
}
