import random
import os

def generate_ori_instructions(num_instructions):
    instructions = []
    for _ in range(num_instructions):
        # 生成一个随机的5位目标寄存器标识符
        rd = random.randint(0, 15)
        # 生成一个随机的5位源寄存器标识符
        rs = random.randint(0, 15)
        # 生成一个随机的16位立即数（0到65535之间）
        imm = random.randint(0, 64)
        # 构造指令：opcode(6 bits) + rs(5 bits) + rt(5 bits) + imm(16 bits)
        instruction = (0b001101 << 26) | (rs << 20) | (rd << 15) | imm
        # 将指令转换为32位的十六进制字符串，并加入列表
        instruction_hex = format(instruction, '08x')
        # 构造汇编指令字符串并打印到终端
        assembly = f"ori $t{rs}, $s{rd}, {imm}"
        print(assembly)
        instructions.append(instruction_hex)
    return instructions

if __name__ == "__main__":
    current_dir = os.path.abspath(os.getcwd())
    num_instructions = 10  # 指定要生成的指令数量
    instructions = generate_ori_instructions(num_instructions)
    with open(".\ori_instructions.mem", "w") as file:
        for instr in instructions:
            file.write(instr + "\n")
